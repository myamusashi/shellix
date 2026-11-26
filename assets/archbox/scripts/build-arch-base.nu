use common.nu *

const ARCH_SIGNING_KEY_FPR = "3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C"
const MIRROR_BASE = "https://geo.mirror.pkgbuild.com"
const BOOT_ID = "fcbox-bootstrap"
const BOOT_TAP = "vm-fcboot"

const SETUP_SCRIPT_TEMPLATE = r##'#!/bin/bash
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
sed -i 's/^CheckSpace/#CheckSpace/' /etc/pacman.conf
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm base openssh sudo rsync git waypipe which
if ! getent group "@TARGET_GID@" >/dev/null; then
    groupadd -g "@TARGET_GID@" "@TARGET_USER@"
fi
if ! id "@TARGET_USER@" >/dev/null 2>&1; then
    useradd -m -u "@TARGET_UID@" -g "@TARGET_GID@" -G wheel -s /bin/bash "@TARGET_USER@"
fi
usermod -p '*' "@TARGET_USER@"
printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "@TARGET_USER@" > "/etc/sudoers.d/10-@TARGET_USER@"
chmod 440 "/etc/sudoers.d/10-@TARGET_USER@"
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
ssh-keygen -A
systemctl enable sshd systemd-networkd
systemctl mask systemd-firstboot.service
pacman -Scc --noconfirm
rm -rf /var/cache/pacman/pkg/*
touch /fcbox-bootstrap-ok
rm -f /fcbox-setup.sh
'##

def main [] {
    if ((^id -u | str trim | into int) != 0) {
        error make --unspanned {
            msg: "fcbox-build-arch-base must be run as root (try: sudo fcbox init-base)"
        }
    }

    if not ($"/sys/class/net/($env.FCBOX_BRIDGE_NAME)" | path exists) {
        error make --unspanned {
            msg: $"Host bridge ($env.FCBOX_BRIDGE_NAME) does not exist yet. Run 'nixos-rebuild switch' first."
        }
    }

    let out_img = $env.FCBOX_BASE_IMAGE_PATH
    let target_user = $env.FCBOX_DEFAULT_USER
    let uid_result = (do { ^id -u $target_user } | complete)
    let target_uid = if $uid_result.exit_code == 0 { $uid_result.stdout | str trim } else { "1000" }
    let gid_result = (do { ^id -g $target_user } | complete)
    let target_gid = if $gid_result.exit_code == 0 { $gid_result.stdout | str trim } else { "100" }

    let bootstrap_url = $"($MIRROR_BASE)/iso/latest/archlinux-bootstrap-x86_64.tar.zst"
    let jail_dir = $"/srv/jailer/firecracker/($BOOT_ID)"
    let jail_root = $"($jail_dir)/root"
    let workdir = (^mktemp -d /tmp/fcbox-arch-build.XXXXXX | str trim)

    try {
        mkdir ($out_img | path dirname)
        print "Downloading Arch Linux bootstrap tarball..."
        let tarball = $"($workdir)/arch-bootstrap.tar.zst"
        let tarball_sig = $"($tarball).sig"
        ^curl -fL $bootstrap_url -o $tarball
        ^curl -fL $"($bootstrap_url).sig" -o $tarball_sig

        print "Verifying Arch Linux bootstrap PGP signature..."
        let gnupghome = $"($workdir)/gnupg"
        mkdir $gnupghome
        ^chmod 700 $gnupghome
        with-env { GNUPGHOME: $gnupghome } {
            ^gpg --batch --import $env.FCBOX_ARCH_RELEASE_SIGNING_KEY
            let expected_fpr_line = $"fpr:::::::::($ARCH_SIGNING_KEY_FPR):"
            let fpr_lines = (^gpg --batch --with-colons --fingerprint $ARCH_SIGNING_KEY_FPR | lines)
            if not ($fpr_lines | any { |line| $line == $expected_fpr_line }) {
                error make --unspanned {
                    msg: "Vendored Arch release signing key does not match expected fingerprint"
                }
            }
            ^gpg --batch --verify $tarball_sig $tarball
        }

        ^tar --zstd -xf $tarball -C $workdir
        let rootfs = $"($workdir)/root.x86_64"

        rm -f $"($rootfs)/etc/resolv.conf"
        $"nameserver ($env.FCBOX_PRIMARY_NAMESERVER)\n" | save -f $"($rootfs)/etc/resolv.conf"
        $"Server = ($MIRROR_BASE)/\$repo/os/\$arch\n" | save -f $"($rootfs)/etc/pacman.d/mirrorlist"

        (
            $SETUP_SCRIPT_TEMPLATE
            | str replace --all "@TARGET_USER@" $target_user
            | str replace --all "@TARGET_UID@" $target_uid
            | str replace --all "@TARGET_GID@" $target_gid
            | save -f $"($rootfs)/fcbox-setup.sh"
        )
        ^chmod 0755 $"($rootfs)/fcbox-setup.sh"

        let jailer_uid = (jailer-uid-for-vm-id 2)
        let firecracker_bin = (resolve-firecracker-binary $env.FCBOX_FIRECRACKER_BIN)

        rm -rf $jail_dir
        mkdir $jail_root
        ^chown $"($jailer_uid):($jailer_uid)" $jail_dir $jail_root
        stage-firecracker-libraries $firecracker_bin $jail_root

        print "Packing bootstrap rootfs into isolated ext4 image (no host mounts)..."
        let base_img = $"($jail_root)/base.ext4"
        ^mke2fs -q -t ext4 -d $rootfs -L arch-base -m 0 $base_img 6G o> /dev/null
        stage-kernel-into-jail $env.FCBOX_VMLINUX_PATH $env.FCBOX_STAGED_KERNEL_PATH $"($jail_root)/vmlinux"
        ^cp -f $env.FCBOX_INITRD_FILE $"($jail_root)/initrd"
        ^chown root:root $"($jail_root)/initrd"
        ^chmod 0444 $"($jail_root)/initrd"
        ^chown $"($jailer_uid):($jailer_uid)" $base_img
        ^chmod 0600 $base_img

        if (do { ^ip link show $BOOT_TAP } | complete).exit_code == 0 {
            ^ip link delete $BOOT_TAP
        }
        ^ip tuntap add name $BOOT_TAP mode tap user ($jailer_uid | into string) vnet_hdr
        ^ip link set $BOOT_TAP master $env.FCBOX_BRIDGE_NAME
        ^ip link set $BOOT_TAP up

        let boot_args = $"(common-boot-args) fcbox.bootstrap=1 fcbox.ip=($env.FCBOX_SUBNET_IP_PREFIX).10.2/($env.FCBOX_SUBNET_PREFIX_LENGTH) fcbox.gw=($env.FCBOX_GATEWAY_ADDRESS)"
        let drives = [
            {
                drive_id: "base"
                path_on_host: "base.ext4"
                is_root_device: false
                is_read_only: false
            }
        ]
        write-vm-config-json $"($jail_root)/vm.json" 2 1024 $boot_args $drives $BOOT_TAP "02:fc:00:00:10:02" $jailer_uid

        let fsize_bytes = (^stat -c '%s' $base_img | str trim | into int)
        let mem_max_bytes = ((1024 + 256) * 1024 * 1024)

        print "Running Arch Linux setup inside isolated Firecracker + jailer MicroVM..."
        let jailer_args = [
            "--id" $BOOT_ID
            "--exec-file" $firecracker_bin
            "--uid" ($jailer_uid | into string)
            "--gid" ($jailer_uid | into string)
            "--chroot-base-dir" "/srv/jailer"
            "--new-pid-ns"
            "--resource-limit" "no-file=1024"
            "--resource-limit" $"fsize=($fsize_bytes)"
            "--cgroup-version" "2"
            "--cgroup" $"memory.max=($mem_max_bytes)"
            "--cgroup" "cpu.max=200000 100000"
            "--"
            "--no-api"
            "--enable-pci"
            "--config-file" "vm.json"
        ]
        ^$env.FCBOX_JAILER_BIN ...$jailer_args

        # With --new-pid-ns, jailer writes the child Firecracker PID and exits 0.
        let boot_pid = (open --raw $"($jail_root)/firecracker.pid" | str trim | into int)
        while (process-alive $boot_pid) {
            sleep 200ms
        }

        let stat_result = (do { ^debugfs -R "stat /fcbox-bootstrap-ok" $base_img } | complete)
        if $stat_result.exit_code != 0 or not ($stat_result.stdout | str contains "Inode:") {
            error make --unspanned {
                msg: "Arch Linux bootstrap inside Firecracker VM did not complete cleanly."
            }
        }

        ^debugfs -w -R "rm /fcbox-bootstrap-ok" $base_img o> /dev/null
        let _ = (do { ^e2fsck -fy $base_img } | complete)
        ^mv $base_img $out_img
        ^chown root:root $out_img
        ^chmod 0444 $out_img
        print $"Built Arch Linux base image at ($out_img)"
    } finally {
        let pid_file = $"($jail_root)/firecracker.pid"
        if ($pid_file | path type) == "file" {
            let pid_str = (try { open --raw $pid_file | str trim } catch { "" })
            if ($pid_str =~ '^[0-9]+$') {
                let pid = ($pid_str | into int)
                if (process-alive $pid) {
                    let _ = (do { ^kill ($pid | into string) } | complete)
                }
            }
        }
        let _ = (do { ^ip link delete $BOOT_TAP } | complete)
        rm -rf $jail_dir $workdir
        let _ = (do { ^rmdir $"/sys/fs/cgroup/firecracker/($BOOT_ID)" } | complete)
    }
}
