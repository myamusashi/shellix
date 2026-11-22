# shellcheck source=common.sh
source "$FCBOX_COMMON_LIBRARY"

VM_NAME="${1:?Missing VM name}"
validate_vm_name "$VM_NAME"
STATE_DIR="/var/lib/microvms/archbox/$VM_NAME"
JAIL_DIR="/srv/jailer/firecracker/$VM_NAME"

if [ -f "$STATE_DIR/config.env" ]; then
    load_vm_config "$STATE_DIR/config.env"
    if [ -n "${VM_TAP:-}" ] && ip link show "$VM_TAP" >/dev/null 2>&1; then
        ip link delete "$VM_TAP" || true
    fi
fi

rm -rf "$JAIL_DIR"
