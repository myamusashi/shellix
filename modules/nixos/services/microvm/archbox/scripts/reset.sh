# shellcheck source=common.sh
source "$FCBOX_COMMON_LIBRARY"

VM_NAME="${1:?Missing VM name}"
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

JAILER_UID="$(jailer_uid_for_vm_id "$VM_ID")"

rm -f "$STATE_DIR/overlay.ext4"
truncate -s "$FCBOX_OVERLAY_SIZE" "$STATE_DIR/overlay.ext4"
mkfs.ext4 -q -F -L fcbox-ovl "$STATE_DIR/overlay.ext4"
chown "$JAILER_UID:$JAILER_UID" "$STATE_DIR/overlay.ext4"
chmod 0600 "$STATE_DIR/overlay.ext4"
