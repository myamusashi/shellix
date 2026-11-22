# shellcheck source=common.sh
source "$FCBOX_COMMON_LIBRARY"

VM_NAME="${1:?Missing VM name}"
validate_vm_name "$VM_NAME"
STATE_DIR="/var/lib/microvms/archbox/$VM_NAME"
load_vm_config "$STATE_DIR/config.env"

JAILER_UID="$(jailer_uid_for_vm_id "$VM_ID")"
FIRECRACKER_BIN="$(resolve_firecracker_binary "$FCBOX_FIRECRACKER_BIN")"

# RLIMIT_FSIZE applies to pwrite offsets on existing sparse ext4 images.
OVERLAY_SIZE="$(stat -c '%s' "$STATE_DIR/overlay.ext4")"
HOME_SIZE="$(stat -c '%s' "$STATE_DIR/home.ext4")"
FSIZE_BYTES="$OVERLAY_SIZE"
if [ "$HOME_SIZE" -gt "$FSIZE_BYTES" ]; then
    FSIZE_BYTES="$HOME_SIZE"
fi
if [ "$FSIZE_BYTES" -lt 67108864 ]; then
    FSIZE_BYTES=67108864
fi

MEM_MAX_BYTES="$(((VM_MEM + 256) * 1024 * 1024))"
CPU_QUOTA_US="$((VM_VCPU * 100000))"

exec "$FCBOX_JAILER_BIN" \
    --id "$VM_NAME" \
    --exec-file "$FIRECRACKER_BIN" \
    --uid "$JAILER_UID" \
    --gid "$JAILER_UID" \
    --chroot-base-dir /srv/jailer \
    --new-pid-ns \
    --resource-limit "no-file=1024" \
    --resource-limit "fsize=$FSIZE_BYTES" \
    --cgroup-version 2 \
    --cgroup "memory.max=$MEM_MAX_BYTES" \
    --cgroup "cpu.max=${CPU_QUOTA_US} 100000" \
    -- \
    --enable-pci \
    --config-file vm.json \
    --api-sock control.socket
