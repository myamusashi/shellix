# shellcheck source=common.sh
source "$FCBOX_COMMON_LIBRARY"

if [ "$(id -u)" -ne 0 ]; then
    echo "fcbox-build-arch-base must be run as root (try: sudo fcbox init-base)" >&2
    exit 1
fi

if [ ! -e "/sys/class/net/$FCBOX_BRIDGE_NAME" ]; then
    echo "Host bridge $FCBOX_BRIDGE_NAME does not exist yet. Run 'nixos-rebuild switch' first." >&2
    exit 1
fi

OUT_IMG="$FCBOX_BASE_IMAGE_PATH"
TARGET_USER="$FCBOX_DEFAULT_USER"
TARGET_UID="$(id -u "$TARGET_USER" 2>/dev/null || echo 1000)"
TARGET_GID="$(id -g "$TARGET_USER" 2>/dev/null || echo 100)"
MIRROR_BASE="https://geo.mirror.pkgbuild.com"
BOOTSTRAP_URL="$MIRROR_BASE/iso/latest/archlinux-bootstrap-x86_64.tar.zst"
BOOT_ID="fcbox-bootstrap"
BOOT_TAP="vm-fcboot"
JAIL_DIR="/srv/jailer/firecracker/$BOOT_ID"
JAIL_ROOT="$JAIL_DIR/root"
BOOT_PID=""

WORKDIR="$(mktemp -d /tmp/fcbox-arch-build.XXXXXX)"
cleanup() {
    if [ -n "$BOOT_PID" ] && kill -0 "$BOOT_PID" 2>/dev/null; then
        kill "$BOOT_PID" 2>/dev/null || true
    fi
    ip link delete "$BOOT_TAP" 2>/dev/null || true
    rm -rf "$JAIL_DIR" "$WORKDIR"
    rmdir "/sys/fs/cgroup/firecracker/$BOOT_ID" 2>/dev/null || true
}
trap cleanup EXIT

mkdir -p "$(dirname "$OUT_IMG")"
echo "Downloading Arch Linux bootstrap tarball..."
curl -fL "$BOOTSTRAP_URL" -o "$WORKDIR/arch-bootstrap.tar.zst"
curl -fL "$BOOTSTRAP_URL.sig" -o "$WORKDIR/arch-bootstrap.tar.zst.sig"

echo "Verifying Arch Linux bootstrap PGP signature..."
GNUPGHOME="$WORKDIR/gnupg"
export GNUPGHOME
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"
gpg --batch --import "$FCBOX_ARCH_RELEASE_SIGNING_KEY"
if ! gpg --batch --with-colons --fingerprint 3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C | grep -q '^fpr:::::::::3E80CA1A8B89F69CBA57D98A76A5EF9054449A5C:$'; then
    echo "Vendored Arch release signing key does not match expected fingerprint" >&2
    exit 1
fi
gpg --batch --verify "$WORKDIR/arch-bootstrap.tar.zst.sig" "$WORKDIR/arch-bootstrap.tar.zst"

tar --zstd -xf "$WORKDIR/arch-bootstrap.tar.zst" -C "$WORKDIR"
ROOTFS="$WORKDIR/root.x86_64"

rm -f "$ROOTFS/etc/resolv.conf"
printf 'nameserver %s\n' "$FCBOX_PRIMARY_NAMESERVER" > "$ROOTFS/etc/resolv.conf"
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

JAILER_UID="$(jailer_uid_for_vm_id 2)"
FIRECRACKER_BIN="$(resolve_firecracker_binary "$FCBOX_FIRECRACKER_BIN")"

rm -rf "$JAIL_DIR"
mkdir -p "$JAIL_ROOT"
chown "$JAILER_UID:$JAILER_UID" "$JAIL_DIR" "$JAIL_ROOT"
stage_firecracker_libraries "$FIRECRACKER_BIN" "$JAIL_ROOT"

echo "Packing bootstrap rootfs into isolated ext4 image (no host mounts)..."
mke2fs -t ext4 -d "$ROOTFS" -L arch-base -m 0 "$JAIL_ROOT/base.ext4" 6G >/dev/null
stage_kernel_into_jail "$FCBOX_VMLINUX_PATH" "$FCBOX_STAGED_KERNEL_PATH" "$JAIL_ROOT/vmlinux"
cp -f "$FCBOX_INITRD_FILE" "$JAIL_ROOT/initrd"
chown root:root "$JAIL_ROOT/initrd"
chmod 0444 "$JAIL_ROOT/initrd"
chown "$JAILER_UID:$JAILER_UID" "$JAIL_ROOT/base.ext4"
chmod 0600 "$JAIL_ROOT/base.ext4"

if ip link show "$BOOT_TAP" >/dev/null 2>&1; then
    ip link delete "$BOOT_TAP"
fi
ip tuntap add name "$BOOT_TAP" mode tap user "$JAILER_UID" vnet_hdr
ip link set "$BOOT_TAP" master "$FCBOX_BRIDGE_NAME"
ip link set "$BOOT_TAP" up

BOOT_ARGS="$(common_boot_args) fcbox.bootstrap=1 fcbox.ip=${FCBOX_SUBNET_IP_PREFIX}.10.2/${FCBOX_SUBNET_PREFIX_LENGTH} fcbox.gw=${FCBOX_GATEWAY_ADDRESS}"
DRIVES_JSON='[{"drive_id":"base","path_on_host":"base.ext4","is_root_device":false,"is_read_only":false}]'
write_vm_config_json "$JAIL_ROOT/vm.json" 2 1024 "$BOOT_ARGS" "$DRIVES_JSON" "$BOOT_TAP" "02:fc:00:00:10:02" "$JAILER_UID"

FSIZE_BYTES="$(stat -c '%s' "$JAIL_ROOT/base.ext4")"
MEM_MAX_BYTES="$(((1024 + 256) * 1024 * 1024))"

echo "Running Arch Linux setup inside isolated Firecracker + jailer MicroVM..."
"$FCBOX_JAILER_BIN" \
    --id "$BOOT_ID" \
    --exec-file "$FIRECRACKER_BIN" \
    --uid "$JAILER_UID" \
    --gid "$JAILER_UID" \
    --chroot-base-dir /srv/jailer \
    --new-pid-ns \
    --resource-limit "no-file=1024" \
    --resource-limit "fsize=$FSIZE_BYTES" \
    --cgroup-version 2 \
    --cgroup "memory.max=$MEM_MAX_BYTES" \
    --cgroup "cpu.max=200000 100000" \
    -- \
    --no-api \
    --enable-pci \
    --config-file vm.json

# With --new-pid-ns, jailer writes the child Firecracker PID and exits 0.
BOOT_PID="$(cat "$JAIL_ROOT/firecracker.pid")"
while kill -0 "$BOOT_PID" 2>/dev/null; do
    sleep 0.2
done
BOOT_PID=""

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
