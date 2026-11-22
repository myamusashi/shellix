{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.services.microvm;
    archCfg = cfg.archbox;

    gatewayIp = lib.head (lib.splitString "/" cfg.subnetCidr);
    subnetPrefix = lib.last (lib.splitString "/" cfg.subnetCidr);
    subnetParts = lib.splitString "." gatewayIp;
    ipPrefix = "${builtins.elemAt subnetParts 0}.${builtins.elemAt subnetParts 1}";

    kernelPkg = archCfg.kernelPackage;
    vmlinuxPath = "${kernelPkg.dev}/vmlinux";

    guestModules = pkgs.makeModulesClosure {
        kernel = kernelPkg.modules or kernelPkg;
        firmware = pkgs.linux-firmware;
        allowMissing = false;
        rootModules = [
            "virtio_pci"
            "virtio_mmio"
            "virtio_blk"
            "virtio_net"
            "virtio_rng"
            "ext4"
            "overlay"
            "af_packet"
            "i8042"
            "atkbd"
        ];
    };

    initScript = pkgs.writeScript "fcbox-init" ''
        #!${pkgs.busybox}/bin/sh
        export PATH=/bin:/sbin:/usr/bin:/usr/sbin
        ${pkgs.busybox}/bin/busybox mkdir -p /bin /sbin /usr/bin /usr/sbin /proc /sys /dev /ro-base /rw-overlay /newroot
        ${pkgs.busybox}/bin/busybox --install -s /bin
        ln -sf ${pkgs.kmod}/bin/kmod /bin/modprobe

        mount -t proc proc /proc
        mount -t sysfs sysfs /sys
        mount -t devtmpfs devtmpfs /dev
        if [ -c /dev/console ]; then
            exec </dev/console >/dev/console 2>&1
        fi

        # Defaults overridden by kernel cmdline
        FC_BOOTSTRAP="0"
        FC_IP=""
        FC_GW="${gatewayIp}"
        FC_DNS="${lib.head cfg.nameservers}"
        FC_HOST="archbox"
        FC_USER="${archCfg.user}"
        FC_UID="1000"
        FC_GID="100"
        FC_PUBKEY_B64=""

        for arg in $(cat /proc/cmdline); do
            case "$arg" in
                fcbox.bootstrap=*) FC_BOOTSTRAP="''${arg#fcbox.bootstrap=}" ;;
                fcbox.ip=*) FC_IP="''${arg#fcbox.ip=}" ;;
                fcbox.gw=*) FC_GW="''${arg#fcbox.gw=}" ;;
                fcbox.dns=*) FC_DNS="''${arg#fcbox.dns=}" ;;
                fcbox.host=*) FC_HOST="''${arg#fcbox.host=}" ;;
                fcbox.user=*) FC_USER="''${arg#fcbox.user=}" ;;
                fcbox.uid=*) FC_UID="''${arg#fcbox.uid=}" ;;
                fcbox.gid=*) FC_GID="''${arg#fcbox.gid=}" ;;
                fcbox.pubkey=*) FC_PUBKEY_B64="''${arg#fcbox.pubkey=}" ;;
            esac
        done

        for mod in virtio_pci virtio_mmio virtio_blk virtio_net virtio_rng ext4 overlay af_packet i8042 atkbd; do
            /bin/modprobe "$mod" || echo "fcbox-init: failed to load $mod"
        done

        if [ "$FC_BOOTSTRAP" = "1" ]; then
            i=0
            while [ ! -b /dev/vda ]; do
                i=$((i + 1))
                if [ "$i" -ge 50 ]; then
                    echo "fcbox-init: timed out waiting for /dev/vda" >&2
                    exec reboot -f
                fi
                sleep 0.1
            done

            j=0
            while [ ! -e /sys/class/net/eth0 ]; do
                j=$((j + 1))
                if [ "$j" -ge 30 ]; then
                    echo "fcbox-init: timed out waiting for eth0" >&2
                    exec reboot -f
                fi
                sleep 0.1
            done

            mount -o rw -t ext4 /dev/vda /newroot

            ip link set lo up
            ip link set eth0 up
            ip addr add "$FC_IP" dev eth0
            ip route add default via "$FC_GW"

            mkdir -p /newroot/proc /newroot/sys /newroot/dev /newroot/run /newroot/tmp
            chmod 1777 /newroot/tmp
            mount -t proc proc /newroot/proc
            mount -t sysfs sysfs /newroot/sys
            mount -t devtmpfs devtmpfs /newroot/dev
            mkdir -p /newroot/dev/pts /newroot/dev/shm
            chmod 1777 /newroot/dev/shm
            mount -t devpts devpts /newroot/dev/pts
            mount -t tmpfs tmpfs /newroot/dev/shm
            ln -sf /proc/self/mounts /newroot/etc/mtab

            chroot /newroot /bin/bash /fcbox-setup.sh || true
            sync
            umount /newroot/dev/shm /newroot/dev/pts /newroot/dev /newroot/sys /newroot/proc /newroot || true
            sync
            exec reboot -f
        fi

        # Wait briefly for virtio block devices
        i=0
        while [ ! -b /dev/vda ] || [ ! -b /dev/vdb ] || [ ! -b /dev/vdc ]; do
            i=$((i + 1))
            if [ "$i" -ge 50 ]; then
                echo "fcbox-init: timed out waiting for /dev/vd[a-c]" >&2
                exec /bin/sh
            fi
            sleep 0.1
        done

        mount -o ro,noload -t ext4 /dev/vda /ro-base
        mount -o rw -t ext4 /dev/vdb /rw-overlay
        mkdir -p /rw-overlay/upper /rw-overlay/work

        mount -t overlay overlay \
            -o "lowerdir=/ro-base,upperdir=/rw-overlay/upper,workdir=/rw-overlay/work" \
            /newroot

        mkdir -p "/newroot/home/$FC_USER"
        mount -o rw -t ext4 /dev/vdc "/newroot/home/$FC_USER"
        chown "$FC_UID:$FC_GID" "/newroot/home/$FC_USER"

        # Ensure kernel modules matching the host-provided vmlinux are visible
        if [ -d /lib/modules ]; then
            mkdir -p /newroot/usr/lib/modules
            mount --bind /lib/modules /newroot/usr/lib/modules
        fi

        echo "$FC_HOST" > /newroot/etc/hostname
        if [ ! -s /newroot/etc/machine-id ]; then
            tr -d '-' < /proc/sys/kernel/random/uuid > /newroot/etc/machine-id
        fi
        mkdir -p /newroot/etc/systemd/system
        ln -sf /dev/null /newroot/etc/systemd/system/systemd-firstboot.service

        mkdir -p /newroot/etc/systemd/network
        if [ -n "$FC_IP" ]; then
            cat > /newroot/etc/systemd/network/20-fcbox.network <<EOF
        [Match]
        Type=ether

        [Network]
        Address=$FC_IP
        Gateway=$FC_GW
        DNS=$FC_DNS
        EOF
        fi

        rm -f /newroot/etc/resolv.conf
        printf 'nameserver %s\n' "$FC_DNS" > /newroot/etc/resolv.conf

        if [ -f /newroot/etc/shadow ]; then
            sed -i "s|^$FC_USER:!:|''${FC_USER}:*:|" /newroot/etc/shadow
        fi

        if [ -n "$FC_PUBKEY_B64" ]; then
            mkdir -p "/newroot/home/$FC_USER/.ssh"
            printf '%s\n' "$FC_PUBKEY_B64" | base64 -d > "/newroot/home/$FC_USER/.ssh/authorized_keys"
            chmod 700 "/newroot/home/$FC_USER/.ssh"
            chmod 600 "/newroot/home/$FC_USER/.ssh/authorized_keys"
            chown -R "$FC_UID:$FC_GID" "/newroot/home/$FC_USER/.ssh"
        fi

        mkdir -p /newroot/proc /newroot/sys /newroot/dev /newroot/run
        mount -t tmpfs -o mode=0755,nosuid,nodev tmpfs /newroot/run
        mount --move /proc /newroot/proc
        mount --move /sys /newroot/sys
        mount --move /dev /newroot/dev

        exec switch_root /newroot /sbin/init
    '';

    initrdImage = pkgs.makeInitrd {
        name = "fcbox-initrd";
        compressor = "gzip";
        contents = [
            {
                object = initScript;
                symlink = "/init";
            }
            {
                object = "${pkgs.busybox}/bin/busybox";
                symlink = "/bin/busybox";
            }
            {
                object = "${pkgs.kmod}/bin/kmod";
                symlink = "/bin/modprobe";
            }
            {
                object = "${guestModules}/lib";
                symlink = "/lib";
            }
        ];
    };

    initrdFile = "${initrdImage}/initrd";

    commonShellLibrary = pkgs.writeText "fcbox-common.sh" ''
        # shellcheck shell=bash

        validate_vm_name() {
            local candidate_name="$1"
            if [[ ! "$candidate_name" =~ ^[a-z0-9][a-z0-9-]{0,30}$ ]]; then
                echo "Invalid VM name '$candidate_name': must match ^[a-z0-9][a-z0-9-]{0,30}$" >&2
                return 1
            fi
        }

        validate_ipv4_address() {
            local address="$1"
            if [[ ! "$address" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
                return 1
            fi
            local octet
            for octet in "''${BASH_REMATCH[1]}" "''${BASH_REMATCH[2]}" "''${BASH_REMATCH[3]}" "''${BASH_REMATCH[4]}"; do
                if [ "$((10#$octet))" -gt 255 ]; then
                    return 1
                fi
            done
        }

        validate_ipv4_cidr() {
            local cidr="$1"
            if [[ ! "$cidr" =~ ^([0-9.]+)/([0-9]{1,2})$ ]]; then
                return 1
            fi
            local address="''${BASH_REMATCH[1]}"
            local prefix="''${BASH_REMATCH[2]}"
            validate_ipv4_address "$address" || return 1
            if [ "$((10#$prefix))" -gt 32 ]; then
                return 1
            fi
        }

        load_vm_config() {
            local config_file="$1"

            if [ ! -f "$config_file" ] || [ -L "$config_file" ]; then
                echo "Config file '$config_file' must exist as a regular file" >&2
                return 1
            fi

            local allowed_pattern='^(VM_ID|VM_IP|VM_HOST_IP|VM_MAC|VM_TAP|VM_MEM|VM_VCPU|VM_USER|VM_OWNER_UID|VM_OWNER_GID|VM_PUBKEY_B64)='
            local bad_lines
            bad_lines="$(grep -nvE "$allowed_pattern" "$config_file" || true)"
            if [ -n "$bad_lines" ]; then
                echo "Malformed or disallowed entries in '$config_file':" >&2
                echo "$bad_lines" >&2
                return 1
            fi

            local key count
            for key in VM_ID VM_IP VM_HOST_IP VM_MAC VM_TAP VM_MEM VM_VCPU VM_USER VM_OWNER_UID VM_OWNER_GID VM_PUBKEY_B64; do
                count="$(grep -cE "^''${key}=" "$config_file" || true)"
                if [ "$count" -ne 1 ]; then
                    echo "Config file '$config_file' must contain exactly one '$key' entry (found $count)" >&2
                    return 1
                fi
            done

            VM_ID="$(grep -E '^VM_ID=' "$config_file" | cut -d= -f2-)"
            VM_IP="$(grep -E '^VM_IP=' "$config_file" | cut -d= -f2-)"
            VM_HOST_IP="$(grep -E '^VM_HOST_IP=' "$config_file" | cut -d= -f2-)"
            VM_MAC="$(grep -E '^VM_MAC=' "$config_file" | cut -d= -f2-)"
            VM_TAP="$(grep -E '^VM_TAP=' "$config_file" | cut -d= -f2-)"
            VM_MEM="$(grep -E '^VM_MEM=' "$config_file" | cut -d= -f2-)"
            VM_VCPU="$(grep -E '^VM_VCPU=' "$config_file" | cut -d= -f2-)"
            VM_USER="$(grep -E '^VM_USER=' "$config_file" | cut -d= -f2-)"
            VM_OWNER_UID="$(grep -E '^VM_OWNER_UID=' "$config_file" | cut -d= -f2-)"
            VM_OWNER_GID="$(grep -E '^VM_OWNER_GID=' "$config_file" | cut -d= -f2-)"
            VM_PUBKEY_B64="$(grep -E '^VM_PUBKEY_B64=' "$config_file" | cut -d= -f2-)"

            if [[ ! "$VM_ID" =~ ^[0-9]+$ ]]; then
                echo "Invalid VM_ID '$VM_ID' in '$config_file'" >&2
                return 1
            fi
            if ! validate_ipv4_cidr "$VM_IP"; then
                echo "Invalid VM_IP '$VM_IP' in '$config_file'" >&2
                return 1
            fi
            if ! validate_ipv4_address "$VM_HOST_IP"; then
                echo "Invalid VM_HOST_IP '$VM_HOST_IP' in '$config_file'" >&2
                return 1
            fi
            if [[ ! "$VM_MAC" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
                echo "Invalid VM_MAC '$VM_MAC' in '$config_file'" >&2
                return 1
            fi
            if [[ ! "$VM_TAP" =~ ^vm-fc[0-9]{1,3}$ ]]; then
                echo "Invalid VM_TAP '$VM_TAP' in '$config_file'" >&2
                return 1
            fi
            if [[ ! "$VM_MEM" =~ ^[1-9][0-9]*$ ]]; then
                echo "Invalid VM_MEM '$VM_MEM' in '$config_file'" >&2
                return 1
            fi
            if [[ ! "$VM_VCPU" =~ ^[1-9][0-9]*$ ]]; then
                echo "Invalid VM_VCPU '$VM_VCPU' in '$config_file'" >&2
                return 1
            fi
            if [[ ! "$VM_USER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
                echo "Invalid VM_USER '$VM_USER' in '$config_file'" >&2
                return 1
            fi
            if [[ ! "$VM_OWNER_UID" =~ ^[0-9]+$ ]]; then
                echo "Invalid VM_OWNER_UID '$VM_OWNER_UID' in '$config_file'" >&2
                return 1
            fi
            if [[ ! "$VM_OWNER_GID" =~ ^[0-9]+$ ]]; then
                echo "Invalid VM_OWNER_GID '$VM_OWNER_GID' in '$config_file'" >&2
                return 1
            fi
            if [[ ! "$VM_PUBKEY_B64" =~ ^[A-Za-z0-9+/]+={0,2}$ ]]; then
                echo "Invalid VM_PUBKEY_B64 in '$config_file'" >&2
                return 1
            fi
        }
    '';

    buildArchBaseScript = pkgs.writeShellApplication {
        name = "fcbox-build-arch-base";
        runtimeInputs = with pkgs; [
            coreutils
            curl
            e2fsprogs
            firecracker
            getent
            glibc.bin
            gnugrep
            gnupg
            gnutar
            iproute2
            jq
            util-linux
            zstd
        ];
        text = ''
            set -euo pipefail

            if [ "$(id -u)" -ne 0 ]; then
                echo "fcbox-build-arch-base must be run as root (try: sudo fcbox init-base)" >&2
                exit 1
            fi

            if [ ! -e "/sys/class/net/${cfg.bridgeName}" ]; then
                echo "Host bridge ${cfg.bridgeName} does not exist yet. Run 'nixos-rebuild switch' first." >&2
                exit 1
            fi

            OUT_IMG="${archCfg.baseImagePath}"
            TARGET_USER="${archCfg.user}"
            TARGET_UID="$(id -u "$TARGET_USER" 2>/dev/null || echo 1000)"
            TARGET_GID="$(id -g "$TARGET_USER" 2>/dev/null || echo 100)"
            MIRROR_BASE="https://geo.mirror.pkgbuild.com"
            BOOTSTRAP_URL="$MIRROR_BASE/iso/latest/archlinux-bootstrap-x86_64.tar.zst"
            BOOT_ID="fcbox-bootstrap"
            BOOT_TAP="vm-fcboot"
            JAIL_DIR="/srv/jailer/firecracker/$BOOT_ID"
            JAIL_ROOT="$JAIL_DIR/root"

            WORKDIR="$(mktemp -d /tmp/fcbox-arch-build.XXXXXX)"
            cleanup() {
                ip link delete "$BOOT_TAP" 2>/dev/null || true
                rm -rf "$JAIL_DIR" "$WORKDIR"
            }
            trap cleanup EXIT

            mkdir -p "$(dirname "$OUT_IMG")"
            echo "Downloading Arch Linux bootstrap tarball..."
            curl -fL "$BOOTSTRAP_URL" -o "$WORKDIR/arch-bootstrap.tar.zst"
            curl -fL "$BOOTSTRAP_URL.sig" -o "$WORKDIR/arch-bootstrap.tar.zst.sig"

            if [ "''${FCBOX_SKIP_PGP:-0}" != "1" ]; then
                echo "Verifying Arch Linux bootstrap PGP signature..."
                GNUPGHOME="$WORKDIR/gnupg"
                export GNUPGHOME
                mkdir -p "$GNUPGHOME"
                chmod 700 "$GNUPGHOME"
                if gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C 2>/dev/null \
                    || gpg --keyserver hkps://keys.openpgp.org --recv-keys 3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C 2>/dev/null; then
                    gpg --verify "$WORKDIR/arch-bootstrap.tar.zst.sig" "$WORKDIR/arch-bootstrap.tar.zst"
                else
                    echo "Warning: Could not fetch Arch release signing key; continuing (set FCBOX_SKIP_PGP=1 to silence)." >&2
                fi
            fi

            tar --zstd -xf "$WORKDIR/arch-bootstrap.tar.zst" -C "$WORKDIR"
            ROOTFS="$WORKDIR/root.x86_64"

            rm -f "$ROOTFS/etc/resolv.conf"
            printf 'nameserver %s\n' "${lib.head cfg.nameservers}" > "$ROOTFS/etc/resolv.conf"
            # shellcheck disable=SC2016
            printf 'Server = %s/$repo/os/$arch\n' "$MIRROR_BASE" > "$ROOTFS/etc/pacman.d/mirrorlist"

            cat > "$ROOTFS/fcbox-setup.sh" <<SETUP_EOF
            #!/bin/bash
            set -euo pipefail
            export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
            sed -i 's/^CheckSpace/#CheckSpace/' /etc/pacman.conf
            pacman-key --init
            pacman-key --populate archlinux
            pacman -Syu --noconfirm base openssh sudo rsync git waypipe which
            if ! getent group "$TARGET_GID" >/dev/null; then
                groupadd -g "$TARGET_GID" "$TARGET_USER"
            fi
            if ! id "$TARGET_USER" >/dev/null 2>&1; then
                useradd -m -u "$TARGET_UID" -g "$TARGET_GID" -G wheel -s /bin/bash "$TARGET_USER"
            fi
            usermod -p '*' "$TARGET_USER"
            printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "$TARGET_USER" > "/etc/sudoers.d/10-$TARGET_USER"
            chmod 440 "/etc/sudoers.d/10-$TARGET_USER"
            sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
            sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
            ssh-keygen -A
            systemctl enable sshd systemd-networkd
            systemctl mask systemd-firstboot.service
            pacman -Scc --noconfirm
            rm -rf /var/cache/pacman/pkg/*
            touch /fcbox-bootstrap-ok
            rm -f /fcbox-setup.sh
            SETUP_EOF
            chmod 0755 "$ROOTFS/fcbox-setup.sh"

            FC_UID="$(id -u fcbox)"
            KVM_GID="$(getent group kvm | cut -d: -f3)"
            FC_BIN="$(readlink -f "${pkgs.firecracker}/bin/firecracker")"

            rm -rf "$JAIL_DIR"
            mkdir -p "$JAIL_ROOT"
            chown "$FC_UID:$KVM_GID" "$JAIL_DIR" "$JAIL_ROOT"

            for libpath in $(ldd "$FC_BIN" | grep -o '/nix/store/[^ ]*'); do
                mkdir -p "$JAIL_ROOT$(dirname "$libpath")"
                ln -f "$libpath" "$JAIL_ROOT$libpath" 2>/dev/null || cp -Lf "$libpath" "$JAIL_ROOT$libpath"
            done

            echo "Packing bootstrap rootfs into isolated ext4 image (no host mounts)..."
            mke2fs -t ext4 -d "$ROOTFS" -L arch-base -m 0 "$JAIL_ROOT/base.ext4" 6G >/dev/null
            cp -f "${vmlinuxPath}" "$JAIL_ROOT/vmlinux"
            cp -f "${initrdFile}" "$JAIL_ROOT/initrd"
            chown "$FC_UID:$KVM_GID" "$JAIL_ROOT/base.ext4" "$JAIL_ROOT/vmlinux" "$JAIL_ROOT/initrd"
            chmod 0660 "$JAIL_ROOT/base.ext4"
            chmod 0444 "$JAIL_ROOT/vmlinux" "$JAIL_ROOT/initrd"

            if ip link show "$BOOT_TAP" >/dev/null 2>&1; then
                ip link delete "$BOOT_TAP"
            fi
            ip tuntap add name "$BOOT_TAP" mode tap user fcbox vnet_hdr
            ip link set "$BOOT_TAP" master "${cfg.bridgeName}"
            ip link set "$BOOT_TAP" up

            BOOT_ARGS="console=ttyS0,115200 reboot=k panic=1 random.trust_cpu=on i8042.noaux i8042.nomux i8042.nopnp i8042.dumbkbd fcbox.bootstrap=1 fcbox.ip=${ipPrefix}.10.2/${subnetPrefix} fcbox.gw=${gatewayIp}"
            jq -n \
                --arg boot_args "$BOOT_ARGS" \
                --arg tap "$BOOT_TAP" \
                '{
                    "boot-source": {
                        "kernel_image_path": "vmlinux",
                        "initrd_path": "initrd",
                        "boot_args": $boot_args
                    },
                    "machine-config": {
                        "vcpu_count": 2,
                        "mem_size_mib": 1024,
                        "smt": true
                    },
                    "entropy": {},
                    "drives": [
                        {
                            "drive_id": "base",
                            "path_on_host": "base.ext4",
                            "is_root_device": false,
                            "is_read_only": false
                        }
                    ],
                    "network-interfaces": [
                        {
                            "iface_id": $tap,
                            "host_dev_name": $tap,
                            "guest_mac": "02:fc:00:00:10:02"
                        }
                    ]
                }' > "$JAIL_ROOT/vm.json"
            chown "$FC_UID:$KVM_GID" "$JAIL_ROOT/vm.json"
            chmod 0440 "$JAIL_ROOT/vm.json"

            echo "Running Arch Linux setup inside isolated Firecracker + jailer MicroVM..."
            "${pkgs.firecracker}/bin/jailer" \
                --id "$BOOT_ID" \
                --exec-file "$FC_BIN" \
                --uid "$FC_UID" \
                --gid "$KVM_GID" \
                --chroot-base-dir /srv/jailer \
                --cgroup-version 2 \
                -- \
                --no-api \
                --enable-pci \
                --config-file vm.json

            if ! debugfs -R "stat /fcbox-bootstrap-ok" "$JAIL_ROOT/base.ext4" 2>/dev/null | grep -q "Inode:"; then
                echo "Arch Linux bootstrap inside Firecracker VM did not complete cleanly." >&2
                exit 1
            fi

            debugfs -w -R "rm /fcbox-bootstrap-ok" "$JAIL_ROOT/base.ext4" >/dev/null
            e2fsck -fy "$JAIL_ROOT/base.ext4" >/dev/null 2>&1 || true
            mv "$JAIL_ROOT/base.ext4" "$OUT_IMG"
            chown root:root "$OUT_IMG"
            chmod 0444 "$OUT_IMG"
            echo "Built Arch Linux base image at $OUT_IMG"
        '';
    };

    fcboxPreStart = pkgs.writeShellApplication {
        name = "fcbox-prestart";
        extraShellCheckFlags = ["-x"];
        runtimeInputs = with pkgs; [
            coreutils
            getent
            glibc.bin
            gnugrep
            iproute2
            jq
            util-linux
        ];
        text = ''
            set -euo pipefail
            source "${commonShellLibrary}"

            VM_NAME="''${1:?Missing VM name}"
            validate_vm_name "$VM_NAME"
            STATE_DIR="/var/lib/microvms/archbox/$VM_NAME"
            JAIL_ROOT="/srv/jailer/firecracker/$VM_NAME/root"

            if [ ! -f "$STATE_DIR/config.env" ]; then
                echo "Missing $STATE_DIR/config.env for archbox '$VM_NAME'" >&2
                exit 1
            fi
            if [ ! -f "${archCfg.baseImagePath}" ]; then
                echo "Missing Arch base image at ${archCfg.baseImagePath}. Run: sudo fcbox init-base" >&2
                exit 1
            fi

            load_vm_config "$STATE_DIR/config.env"

            FC_UID="$(id -u fcbox)"
            KVM_GID="$(getent group kvm | cut -d: -f3)"
            FC_BIN="$(readlink -f "${pkgs.firecracker}/bin/firecracker")"

            # Setup TAP attached to host bridge
            if ip link show "$VM_TAP" >/dev/null 2>&1; then
                ip link delete "$VM_TAP"
            fi
            ip tuntap add name "$VM_TAP" mode tap user fcbox vnet_hdr
            ip link set "$VM_TAP" master "${cfg.bridgeName}"
            ip link set "$VM_TAP" up

            rm -rf "$JAIL_ROOT"
            mkdir -p "$JAIL_ROOT"
            chown "$FC_UID:$KVM_GID" "/srv/jailer/firecracker/$VM_NAME" "$JAIL_ROOT"

            for libpath in $(ldd "$FC_BIN" | grep -o '/nix/store/[^ ]*'); do
                mkdir -p "$JAIL_ROOT$(dirname "$libpath")"
                ln -f "$libpath" "$JAIL_ROOT$libpath" 2>/dev/null || cp -Lf "$libpath" "$JAIL_ROOT$libpath"
            done

            # Stage kernel, initrd, base, overlay, and isolated home inside jailer chroot
            cp -f "${vmlinuxPath}" "$JAIL_ROOT/vmlinux"
            cp -f "${initrdFile}" "$JAIL_ROOT/initrd"
            chown root:root "$JAIL_ROOT/vmlinux" "$JAIL_ROOT/initrd"
            chmod 0444 "$JAIL_ROOT/vmlinux" "$JAIL_ROOT/initrd"

            # Keep the shared base image root:root 0444 without mutating the hardlinked inode.
            if ! ln -f "${archCfg.baseImagePath}" "$JAIL_ROOT/base.ext4" 2>/dev/null; then
                cp -f "${archCfg.baseImagePath}" "$JAIL_ROOT/base.ext4"
                chown root:root "$JAIL_ROOT/base.ext4"
                chmod 0444 "$JAIL_ROOT/base.ext4"
            fi

            ln -f "$STATE_DIR/overlay.ext4" "$JAIL_ROOT/overlay.ext4" 2>/dev/null \
                || { echo "overlay.ext4 must live on the same filesystem as /srv/jailer for hardlinking" >&2; exit 1; }
            ln -f "$STATE_DIR/home.ext4" "$JAIL_ROOT/home.ext4" 2>/dev/null \
                || { echo "home.ext4 must live on the same filesystem as /srv/jailer for hardlinking" >&2; exit 1; }

            chown "$FC_UID:$KVM_GID" \
                "$JAIL_ROOT/overlay.ext4" \
                "$JAIL_ROOT/home.ext4"
            chmod 0600 "$JAIL_ROOT/overlay.ext4" "$JAIL_ROOT/home.ext4"

            BOOT_ARGS="console=ttyS0,115200 reboot=k panic=1 random.trust_cpu=on i8042.noaux i8042.nomux i8042.nopnp i8042.dumbkbd fcbox.ip=$VM_IP fcbox.gw=${gatewayIp} fcbox.dns=${lib.head cfg.nameservers} fcbox.host=$VM_NAME fcbox.user=$VM_USER fcbox.uid=$VM_OWNER_UID fcbox.gid=$VM_OWNER_GID fcbox.pubkey=$VM_PUBKEY_B64"

            jq -n \
                --argjson vcpu "$VM_VCPU" \
                --argjson mem "$VM_MEM" \
                --arg boot_args "$BOOT_ARGS" \
                --arg tap "$VM_TAP" \
                --arg mac "$VM_MAC" \
                '{
                    "boot-source": {
                        "kernel_image_path": "vmlinux",
                        "initrd_path": "initrd",
                        "boot_args": $boot_args
                    },
                    "machine-config": {
                        "vcpu_count": $vcpu,
                        "mem_size_mib": $mem,
                        "smt": true
                    },
                    "entropy": {},
                    "drives": [
                        {
                            "drive_id": "base",
                            "path_on_host": "base.ext4",
                            "is_root_device": false,
                            "is_read_only": true
                        },
                        {
                            "drive_id": "overlay",
                            "path_on_host": "overlay.ext4",
                            "is_root_device": false,
                            "is_read_only": false
                        },
                        {
                            "drive_id": "home",
                            "path_on_host": "home.ext4",
                            "is_root_device": false,
                            "is_read_only": false
                        }
                    ],
                    "network-interfaces": [
                        {
                            "iface_id": $tap,
                            "host_dev_name": $tap,
                            "guest_mac": $mac
                        }
                    ]
                }' > "$JAIL_ROOT/vm.json"
            chown "$FC_UID:$KVM_GID" "$JAIL_ROOT/vm.json"
            chmod 0440 "$JAIL_ROOT/vm.json"
        '';
    };

    fcboxExecStart = pkgs.writeShellApplication {
        name = "fcbox-run";
        extraShellCheckFlags = ["-x"];
        runtimeInputs = with pkgs; [
            coreutils
            firecracker
            getent
            gnugrep
        ];
        text = ''
            set -euo pipefail
            source "${commonShellLibrary}"

            VM_NAME="''${1:?Missing VM name}"
            validate_vm_name "$VM_NAME"
            FC_UID="$(id -u fcbox)"
            KVM_GID="$(getent group kvm | cut -d: -f3)"
            FC_BIN="$(readlink -f "${pkgs.firecracker}/bin/firecracker")"

            exec "${pkgs.firecracker}/bin/jailer" \
                --id "$VM_NAME" \
                --exec-file "$FC_BIN" \
                --uid "$FC_UID" \
                --gid "$KVM_GID" \
                --chroot-base-dir /srv/jailer \
                --cgroup-version 2 \
                -- \
                --enable-pci \
                --config-file vm.json \
                --api-sock control.socket
        '';
    };

    fcboxExecStop = pkgs.writeShellApplication {
        name = "fcbox-stop";
        extraShellCheckFlags = ["-x"];
        runtimeInputs = with pkgs; [
            coreutils
            curl
            gnugrep
            iproute2
        ];
        text = ''
            set -euo pipefail
            source "${commonShellLibrary}"

            VM_NAME="''${1:?Missing VM name}"
            validate_vm_name "$VM_NAME"
            STATE_DIR="/var/lib/microvms/archbox/$VM_NAME"
            JAIL_DIR="/srv/jailer/firecracker/$VM_NAME"
            SOCK="$JAIL_DIR/root/control.socket"

            if [ -S "$SOCK" ]; then
                curl -s --unix-socket "$SOCK" \
                    -X PUT http://localhost/actions \
                    -d '{"action_type": "SendCtrlAltDel"}' || true
                sleep 1
            fi

            if [ -f "$STATE_DIR/config.env" ]; then
                load_vm_config "$STATE_DIR/config.env"
                if [ -n "''${VM_TAP:-}" ] && ip link show "$VM_TAP" >/dev/null 2>&1; then
                    ip link delete "$VM_TAP" || true
                fi
            fi

            rm -rf "$JAIL_DIR"
        '';
    };

    fcboxReset = pkgs.writeShellApplication {
        name = "fcbox-reset";
        extraShellCheckFlags = ["-x"];
        runtimeInputs = with pkgs; [
            coreutils
            e2fsprogs
            getent
            gnugrep
            systemd
        ];
        text = ''
            set -euo pipefail
            source "${commonShellLibrary}"

            VM_NAME="''${1:?Missing VM name}"
            validate_vm_name "$VM_NAME"
            STATE_DIR="/var/lib/microvms/archbox/$VM_NAME"

            if [ -L "$STATE_DIR" ] || [ ! -d "$STATE_DIR" ]; then
                echo "Invalid state directory '$STATE_DIR'" >&2
                exit 1
            fi
            if [ ! -f "$STATE_DIR/config.env" ]; then
                echo "Missing $STATE_DIR/config.env for archbox '$VM_NAME'" >&2
                exit 1
            fi

            load_vm_config "$STATE_DIR/config.env"

            if systemctl is-active --quiet "fcbox@$VM_NAME.service"; then
                echo "Refusing to reset overlay while fcbox@$VM_NAME.service is active" >&2
                exit 1
            fi

            FC_UID="$(id -u fcbox)"
            KVM_GID="$(getent group kvm | cut -d: -f3)"

            rm -f "$STATE_DIR/overlay.ext4"
            truncate -s "${archCfg.overlaySize}" "$STATE_DIR/overlay.ext4"
            mkfs.ext4 -q -F -L fcbox-ovl "$STATE_DIR/overlay.ext4"
            chown "$FC_UID:$KVM_GID" "$STATE_DIR/overlay.ext4"
            chmod 0600 "$STATE_DIR/overlay.ext4"
        '';
    };

    fcboxCli = pkgs.writeShellApplication {
        name = "fcbox";
        extraShellCheckFlags = ["-x"];
        runtimeInputs = with pkgs; [
            coreutils
            e2fsprogs
            gnugrep
            openssh
            rsync
            systemd
            util-linux
            waypipe
        ];
        text = ''
            set -euo pipefail
            source "${commonShellLibrary}"

            BASE_DIR="/var/lib/microvms/archbox"
            SSH_KEY_DIR="$HOME/.local/share/fcbox"
            SSH_KEY="$SSH_KEY_DIR/id_ed25519"

            usage() {
                cat <<EOF
            fcbox - Firecracker Arch Linux MicroVM (Distrobox replacement)

            Usage:
              fcbox init-base                         Build Arch Linux base image (requires sudo/root)
              fcbox create <name> [--copy-home] [--home-full] [--mem MB] [--vcpu N]
              fcbox enter <name> [--waypipe]          Start VM if stopped and open interactive shell
              fcbox run <name> -- <cmd...>            Run a command inside the VM
              fcbox sync-home <name> [--home-full]    One-way rsync of host \$HOME into isolated VM \$HOME
              fcbox pull <name> <vm-path> <host-path> Copy files out of VM isolation
              fcbox reset <name>                      Wipe overlay.ext4 (keep isolated home.ext4)
              fcbox stop <name>                       Stop VM
              fcbox rm <name>                         Stop and delete VM state
              fcbox list                              List configured fcbox VMs
            EOF
            }

            ensure_ssh_key() {
                mkdir -p "$SSH_KEY_DIR"
                chmod 700 "$SSH_KEY_DIR"
                if [ ! -f "$SSH_KEY" ]; then
                    ssh-keygen -t ed25519 -N "" -f "$SSH_KEY" -C "fcbox@$HOSTNAME" >/dev/null
                fi
            }

            next_ip_octet() {
                local used max=10
                if [ -d "$BASE_DIR" ]; then
                    for f in "$BASE_DIR"/*/config.env; do
                        [ -f "$f" ] || continue
                        used="$(grep -E '^VM_ID=' "$f" | cut -d= -f2 || true)"
                        if [ -n "$used" ] && [ "$used" -ge "$max" ]; then
                            max=$((used + 1))
                        fi
                    done
                fi
                echo "$max"
            }

            wait_ssh() {
                local name="$1" ip="$2" user="$3" i=0
                while ! ssh -i "$SSH_KEY" -o BatchMode=yes -o StrictHostKeyChecking=no \
                    -o UserKnownHostsFile=/dev/null -o ConnectTimeout=1 \
                    "$user@$ip" true 2>/dev/null; do
                    if ! systemctl is-active --quiet "fcbox@$name.service"; then
                        echo "fcbox@$name.service exited before SSH became ready. Check: journalctl -u fcbox@$name.service -n 50" >&2
                        return 1
                    fi
                    i=$((i + 1))
                    if [ "$i" -ge 60 ]; then
                        echo "Timed out waiting for SSH on $ip" >&2
                        return 1
                    fi
                    sleep 0.5
                done
            }

            stage_home_image() {
                local home_img="$1" full_copy="$2"
                local stage
                stage="$(mktemp -d /tmp/fcbox-home-stage.XXXXXX)"
                trap 'rm -rf "$stage"' RETURN

                local excludes=(
                    "--exclude=.cache"
                    "--exclude=.local/share/Trash"
                    "--exclude=.local/share/Steam"
                    "--exclude=.local/share/fcbox"
                    "--exclude=*.qcow2"
                    "--exclude=*.ext4"
                )
                if [ "$full_copy" = "1" ]; then
                    excludes=("--exclude=.local/share/fcbox")
                fi

                echo "Copying \$HOME into isolated ext4 volume..."
                rsync -a --delete "''${excludes[@]}" "$HOME/" "$stage/"
                mke2fs -t ext4 -d "$stage" -L fcbox-home -m 1 "$home_img" "${archCfg.homeSize}" >/dev/null
                chmod 0660 "$home_img"
            }

            cmd="''${1:-help}"
            shift || true

            case "$cmd" in
                init-base)
                    exec sudo ${lib.getExe buildArchBaseScript} "$@"
                    ;;
                create)
                    NAME="''${1:?Missing VM name}"
                    validate_vm_name "$NAME"
                    shift
                    COPY_HOME=0
                    FULL_HOME=0
                    VM_MEM="${toString archCfg.defaultMem}"
                    VM_VCPU="${toString archCfg.defaultVcpu}"

                    while [ $# -gt 0 ]; do
                        case "$1" in
                            --copy-home) COPY_HOME=1 ;;
                            --home-full) COPY_HOME=1; FULL_HOME=1 ;;
                            --mem) shift; VM_MEM="''${1:?Missing value for --mem}" ;;
                            --vcpu) shift; VM_VCPU="''${1:?Missing value for --vcpu}" ;;
                            *) echo "Unknown option: $1" >&2; exit 1 ;;
                        esac
                        shift
                    done

                    if [[ ! "$VM_MEM" =~ ^[1-9][0-9]*$ ]]; then
                        echo "Invalid --mem value '$VM_MEM': must be a positive integer" >&2
                        exit 1
                    fi
                    if [[ ! "$VM_VCPU" =~ ^[1-9][0-9]*$ ]]; then
                        echo "Invalid --vcpu value '$VM_VCPU': must be a positive integer" >&2
                        exit 1
                    fi

                    if [ ! -f "${archCfg.baseImagePath}" ]; then
                        echo "Arch base image not found at ${archCfg.baseImagePath}. Run: fcbox init-base" >&2
                        exit 1
                    fi

                    VM_DIR="$BASE_DIR/$NAME"
                    if [ -d "$VM_DIR" ]; then
                        echo "fcbox '$NAME' already exists at $VM_DIR" >&2
                        exit 1
                    fi

                    ensure_ssh_key
                    VM_ID="$(next_ip_octet)"
                    VM_IP="${ipPrefix}.10.$VM_ID/${subnetPrefix}"
                    VM_HOST_IP="${ipPrefix}.10.$VM_ID"
                    HEX_ID="$(printf '%02x' "$VM_ID")"
                    VM_MAC="02:fc:00:00:10:$HEX_ID"
                    VM_TAP="vm-fc$VM_ID"
                    PUBKEY_B64="$(base64 -w0 "$SSH_KEY.pub")"

                    mkdir -p "$VM_DIR"
                    chmod 2775 "$VM_DIR"
                    truncate -s "${archCfg.overlaySize}" "$VM_DIR/overlay.ext4"
                    mkfs.ext4 -q -L fcbox-ovl "$VM_DIR/overlay.ext4"
                    chmod 0660 "$VM_DIR/overlay.ext4"

                    if [ "$COPY_HOME" = "1" ]; then
                        stage_home_image "$VM_DIR/home.ext4" "$FULL_HOME"
                    else
                        truncate -s "${archCfg.homeSize}" "$VM_DIR/home.ext4"
                        mkfs.ext4 -q -L fcbox-home "$VM_DIR/home.ext4"
                        chmod 0660 "$VM_DIR/home.ext4"
                    fi

                    cat > "$VM_DIR/config.env" <<EOF
            VM_ID=$VM_ID
            VM_IP=$VM_IP
            VM_HOST_IP=$VM_HOST_IP
            VM_MAC=$VM_MAC
            VM_TAP=$VM_TAP
            VM_MEM=$VM_MEM
            VM_VCPU=$VM_VCPU
            VM_USER=$USER
            VM_OWNER_UID=$(id -u)
            VM_OWNER_GID=$(id -g)
            VM_PUBKEY_B64=$PUBKEY_B64
            EOF
                    echo "Created fcbox '$NAME' ($VM_HOST_IP, copy-home=$COPY_HOME)"
                    ;;
                enter)
                    NAME="''${1:?Missing VM name}"
                    validate_vm_name "$NAME"
                    shift
                    USE_WAYPIPE=0
                    if [ "''${1:-}" = "--waypipe" ]; then
                        USE_WAYPIPE=1
                        shift
                    fi
                    VM_DIR="$BASE_DIR/$NAME"
                    load_vm_config "$VM_DIR/config.env"
                    systemctl start "fcbox@$NAME.service"
                    wait_ssh "$NAME" "$VM_HOST_IP" "$VM_USER"
                    if [ "$USE_WAYPIPE" = "1" ]; then
                        exec waypipe ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no \
                            -o UserKnownHostsFile=/dev/null "$VM_USER@$VM_HOST_IP" "$@"
                    elif command -v kitten >/dev/null 2>&1; then
                        exec kitten ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no \
                            -o UserKnownHostsFile=/dev/null "$VM_USER@$VM_HOST_IP" "$@"
                    else
                        exec ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no \
                            -o UserKnownHostsFile=/dev/null "$VM_USER@$VM_HOST_IP" "$@"
                    fi
                    ;;
                run)
                    NAME="''${1:?Missing VM name}"
                    validate_vm_name "$NAME"
                    shift
                    [ "''${1:-}" = "--" ] && shift
                    VM_DIR="$BASE_DIR/$NAME"
                    load_vm_config "$VM_DIR/config.env"
                    systemctl start "fcbox@$NAME.service"
                    wait_ssh "$NAME" "$VM_HOST_IP" "$VM_USER"
                    exec ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null "$VM_USER@$VM_HOST_IP" "$@"
                    ;;
                sync-home)
                    NAME="''${1:?Missing VM name}"
                    validate_vm_name "$NAME"
                    shift
                    FULL_HOME=0
                    [ "''${1:-}" = "--home-full" ] && FULL_HOME=1
                    VM_DIR="$BASE_DIR/$NAME"
                    load_vm_config "$VM_DIR/config.env"
                    systemctl start "fcbox@$NAME.service"
                    wait_ssh "$NAME" "$VM_HOST_IP" "$VM_USER"
                    excludes=("--exclude=.cache" "--exclude=.local/share/Trash" "--exclude=.local/share/Steam" "--exclude=.local/share/fcbox")
                    [ "$FULL_HOME" = "1" ] && excludes=("--exclude=.local/share/fcbox")
                    exec rsync -av "''${excludes[@]}" \
                        -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
                        "$HOME/" "$VM_USER@$VM_HOST_IP:/home/$VM_USER/"
                    ;;
                pull)
                    NAME="''${1:?Missing VM name}"
                    validate_vm_name "$NAME"
                    SRC="''${2:?Missing remote path}"
                    DST="''${3:?Missing local destination}"
                    VM_DIR="$BASE_DIR/$NAME"
                    load_vm_config "$VM_DIR/config.env"
                    wait_ssh "$NAME" "$VM_HOST_IP" "$VM_USER"
                    exec rsync -av \
                        -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
                        "$VM_USER@$VM_HOST_IP:$SRC" "$DST"
                    ;;
                reset)
                    NAME="''${1:?Missing VM name}"
                    validate_vm_name "$NAME"
                    systemctl start "fcbox-reset@$NAME.service"
                    echo "Reset root overlay for '$NAME' (isolated home.ext4 preserved)."
                    ;;
                stop)
                    NAME="''${1:?Missing VM name}"
                    validate_vm_name "$NAME"
                    exec systemctl stop "fcbox@$NAME.service"
                    ;;
                rm)
                    NAME="''${1:?Missing VM name}"
                    validate_vm_name "$NAME"
                    systemctl stop "fcbox@$NAME.service" || true
                    rm -rf "''${BASE_DIR:?}/''${NAME:?}"
                    echo "Removed fcbox '$NAME'."
                    ;;
                list)
                    if [ -d "$BASE_DIR" ]; then
                        for d in "$BASE_DIR"/*; do
                            [ -f "$d/config.env" ] || continue
                            name="$(basename "$d")"
                            validate_vm_name "$name" || continue
                            load_vm_config "$d/config.env" || continue
                            state="$(systemctl is-active "fcbox@$name.service" 2>/dev/null || true)"
                            printf '%-20s %-16s %-10s\n' "$name" "$VM_HOST_IP" "$state"
                        done
                    fi
                    ;;
                *)
                    usage
                    ;;
            esac
        '';
    };
in {
    options.shellix.services.microvm.archbox = {
        enable = lib.mkEnableOption "Enable jailer-isolated Arch Linux Firecracker MicroVMs (Distrobox replacement)";

        user = lib.mkOption {
            type = lib.types.str;
            default = "myamusashi";
            description = "Default host user provisioned in Arch Linux MicroVMs.";
        };

        defaultMem = lib.mkOption {
            type = lib.types.ints.positive;
            default = 2048;
            description = "Default memory in MiB for created Arch Linux MicroVMs.";
        };

        defaultVcpu = lib.mkOption {
            type = lib.types.ints.positive;
            default = 2;
            description = "Default vCPU count for created Arch Linux MicroVMs.";
        };

        homeSize = lib.mkOption {
            type = lib.types.str;
            default = "16G";
            description = "Sparse ext4 size for isolated per-VM \$HOME volumes.";
        };

        overlaySize = lib.mkOption {
            type = lib.types.str;
            default = "16G";
            description = "Sparse ext4 size for writable rootfs overlay volumes.";
        };

        baseImagePath = lib.mkOption {
            type = lib.types.path;
            default = "/var/lib/microvms/images/archlinux-base.ext4";
            description = "Path to the shared read-only Arch Linux ext4 base image.";
        };

        kernelPackage = lib.mkOption {
            type = lib.types.package;
            default = pkgs.linuxPackages.kernel;
            defaultText = lib.literalExpression "pkgs.linuxPackages.kernel";
            description = "Linux kernel package providing uncompressed vmlinux and virtio modules for Arch Linux MicroVMs.";
        };
    };

    config = lib.mkIf (cfg.enable && archCfg.enable) {
        users.groups.microvm = {};
        users.users.fcbox = {
            isSystemUser = true;
            group = "kvm";
            extraGroups = ["microvm"];
            description = "Unprivileged Firecracker jailer user for fcbox MicroVMs";
        };

        environment.systemPackages = with pkgs; [
            fcboxCli
            buildArchBaseScript
            waypipe
        ];

        systemd = {
            tmpfiles.rules = [
                "d /var/lib/microvms 0775 microvm kvm -"
                "d /var/lib/microvms/images 0755 root root -"
                "d /var/lib/microvms/archbox 2775 fcbox microvm -"
                "d /srv/jailer 0755 root root -"
                "d /srv/jailer/firecracker 0755 root root -"
            ];

            services = {
                "fcbox@" = {
                    description = "Jailer-isolated Arch Linux Firecracker MicroVM (%i)";
                    after = [
                        "network.target"
                        "systemd-networkd.service"
                    ];
                    wants = ["systemd-networkd.service"];
                    serviceConfig = {
                        Type = "simple";
                        ExecStartPre = "${lib.getExe fcboxPreStart} %i";
                        ExecStart = "${lib.getExe fcboxExecStart} %i";
                        ExecStopPost = "${lib.getExe fcboxExecStop} %i";
                        LimitNOFILE = 1048576;
                        LimitMEMLOCK = "infinity";
                        Restart = "no";
                    };
                };

                "fcbox-reset@" = {
                    description = "Reset rootfs overlay for Arch Linux Firecracker MicroVM (%i)";
                    conflicts = ["fcbox@%i.service"];
                    after = ["fcbox@%i.service"];
                    serviceConfig = {
                        Type = "oneshot";
                        ExecStart = "${lib.getExe fcboxReset} %i";
                    };
                };
            };
        };

        # Allow microvm/wheel group users to manage fcbox@*.service and fcbox-reset@*.service without sudo prompts.
        security.polkit.extraConfig = ''
            polkit.addRule(function(action, subject) {
                if (action.id == "org.freedesktop.systemd1.manage-units" &&
                    /^fcbox(-reset)?@[a-z0-9][a-z0-9-]{0,30}\.service$/.test(action.lookup("unit")) &&
                    (subject.isInGroup("microvm") || subject.isInGroup("wheel"))) {
                    return polkit.Result.YES;
                }
            });
        '';
    };
}
