# shellcheck source=common.sh
source "$FCBOX_COMMON_LIBRARY"

VM_NAME="${1:?Missing VM name}"
validate_vm_name "$VM_NAME"
JAIL_ROOT="/srv/jailer/firecracker/$VM_NAME/root"
SOCK="$JAIL_ROOT/control.socket"
PID_FILE="$JAIL_ROOT/firecracker.pid"

TARGET_PID="${MAINPID:-}"
if [ -z "$TARGET_PID" ] && [ -f "$PID_FILE" ] && [ ! -L "$PID_FILE" ]; then
    TARGET_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
fi
if [[ ! "$TARGET_PID" =~ ^[0-9]+$ ]]; then
    TARGET_PID=""
fi

if [ -S "$SOCK" ]; then
    curl -fsS --max-time 5 --unix-socket "$SOCK" \
        -X PUT http://localhost/actions \
        -d '{"action_type": "SendCtrlAltDel"}' >/dev/null 2>&1 || true
fi

# Wait up to 20s for Firecracker to exit cleanly before systemd sends SIGTERM.
if [ -n "$TARGET_PID" ]; then
    waited=0
    while [ "$waited" -lt 100 ]; do
        if ! kill -0 "$TARGET_PID" 2>/dev/null; then
            exit 0
        fi
        sleep 0.2
        waited=$((waited + 1))
    done
fi
