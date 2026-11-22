# shellcheck source=common.sh
source "$FCBOX_COMMON_LIBRARY"

VM_NAME="${1:?Missing VM name}"
validate_vm_name "$VM_NAME"
STATE_DIR="/var/lib/microvms/archbox/$VM_NAME"
JAIL_ROOT="/srv/jailer/firecracker/$VM_NAME/root"

if [ ! -f "$STATE_DIR/config.env" ]; then
    echo "Missing $STATE_DIR/config.env for archbox '$VM_NAME'" >&2
    exit 1
fi
if [ ! -f "$FCBOX_BASE_IMAGE_PATH" ]; then
    echo "Missing Arch base image at $FCBOX_BASE_IMAGE_PATH. Run: sudo fcbox init-base" >&2
    exit 1
fi

load_vm_config "$STATE_DIR/config.env"

JAILER_UID="$(jailer_uid_for_vm_id "$VM_ID")"
FIRECRACKER_BIN="$(resolve_firecracker_binary "$FCBOX_FIRECRACKER_BIN")"

if ip link show "$VM_TAP" >/dev/null 2>&1; then
    ip link delete "$VM_TAP"
fi
ip tuntap add name "$VM_TAP" mode tap user "$JAILER_UID" vnet_hdr
ip link set "$VM_TAP" master "$FCBOX_BRIDGE_NAME"
ip link set "$VM_TAP" up

rm -rf "$JAIL_ROOT"
mkdir -p "$JAIL_ROOT"
chown "$JAILER_UID:$JAILER_UID" "/srv/jailer/firecracker/$VM_NAME" "$JAIL_ROOT"
stage_firecracker_libraries "$FIRECRACKER_BIN" "$JAIL_ROOT"

stage_kernel_into_jail "$FCBOX_VMLINUX_PATH" "$FCBOX_STAGED_KERNEL_PATH" "$JAIL_ROOT/vmlinux"
cp -f "$FCBOX_INITRD_FILE" "$JAIL_ROOT/initrd"
chown root:root "$JAIL_ROOT/initrd"
chmod 0444 "$JAIL_ROOT/initrd"

# Keep the shared base image root:root 0444 without mutating the hardlinked inode.
if ! ln -f "$FCBOX_BASE_IMAGE_PATH" "$JAIL_ROOT/base.ext4" 2>/dev/null; then
    cp -f "$FCBOX_BASE_IMAGE_PATH" "$JAIL_ROOT/base.ext4"
    chown root:root "$JAIL_ROOT/base.ext4"
    chmod 0444 "$JAIL_ROOT/base.ext4"
fi

ln -f "$STATE_DIR/overlay.ext4" "$JAIL_ROOT/overlay.ext4" 2>/dev/null \
    || { echo "overlay.ext4 must live on the same filesystem as /srv/jailer for hardlinking" >&2; exit 1; }
ln -f "$STATE_DIR/home.ext4" "$JAIL_ROOT/home.ext4" 2>/dev/null \
    || { echo "home.ext4 must live on the same filesystem as /srv/jailer for hardlinking" >&2; exit 1; }

chown "$JAILER_UID:$JAILER_UID" \
    "$JAIL_ROOT/overlay.ext4" \
    "$JAIL_ROOT/home.ext4"
chmod 0600 "$JAIL_ROOT/overlay.ext4" "$JAIL_ROOT/home.ext4"

BOOT_ARGS="$(common_boot_args) fcbox.ip=$VM_IP fcbox.gw=$FCBOX_GATEWAY_ADDRESS fcbox.dns=$FCBOX_PRIMARY_NAMESERVER fcbox.host=$VM_NAME fcbox.user=$VM_USER fcbox.uid=$VM_OWNER_UID fcbox.gid=$VM_OWNER_GID fcbox.pubkey=$VM_PUBKEY_B64"
DRIVES_JSON='[{"drive_id":"base","path_on_host":"base.ext4","is_root_device":false,"is_read_only":true},{"drive_id":"overlay","path_on_host":"overlay.ext4","is_root_device":false,"is_read_only":false,"cache_type":"Writeback"},{"drive_id":"home","path_on_host":"home.ext4","is_root_device":false,"is_read_only":false,"cache_type":"Writeback"}]'
write_vm_config_json "$JAIL_ROOT/vm.json" "$VM_VCPU" "$VM_MEM" "$BOOT_ARGS" "$DRIVES_JSON" "$VM_TAP" "$VM_MAC" "$JAILER_UID"
