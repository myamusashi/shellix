# shellcheck source=common.sh
source "$FCBOX_COMMON_LIBRARY"

BASE_DIR="/var/lib/microvms/archbox"
SSH_KEY_DIR="$HOME/.local/share/fcbox"
SSH_KEY="$SSH_KEY_DIR/id_ed25519"
CLEANUP_PATHS=()

cleanup_temp_paths() {
    local path
    for path in "${CLEANUP_PATHS[@]}"; do
        if [ -n "$path" ]; then
            rm -rf "$path"
        fi
    done
}
trap cleanup_temp_paths EXIT

# Always excluded from VM home images and sync-home, even with --home-full.
HOME_SECRET_DENYLIST=(
    "/.ssh"
    "/.gnupg"
    "/.config/sops"
    "/.local/share/keyrings"
    "/.local/share/fcbox"
    "/.password-store"
    "/password-store"
    "/.mozilla"
    "/.config/chromium"
    "/.config/google-chrome"
    "/.zen"
    "/zen"
    "/.config/zen"
    "/.librewolf"
    "/librewolf"
    "*.ext4"
)

HOME_DEFAULT_EXCLUDES=(
    "/.cache"
    "/.local/share/Trash"
    "/.local/share/Steam"
    "*.qcow2"
)

build_home_rsync_args() {
    local full_copy="$1"
    shift
    HOME_RSYNC_ARGS=("--exclude=/.ssh/authorized_keys")

    local raw_path include_path prefix part idx last_idx
    local -a parts
    for raw_path in "$@"; do
        include_path="$raw_path"
        while [[ "$include_path" == ./* ]]; do
            include_path="${include_path#./}"
        done
        while [[ "$include_path" == /* ]]; do
            include_path="${include_path#/}"
        done
        while [[ "$include_path" == */ ]]; do
            include_path="${include_path%/}"
        done

        if [ -z "$include_path" ] || [[ "$include_path" == ".." ]] || [[ "$include_path" == ../* ]] || [[ "$include_path" == */../* ]] || [[ "$include_path" == */.. ]]; then
            echo "Invalid --include path '$raw_path'" >&2
            return 1
        fi
        if [ "$include_path" = ".ssh/authorized_keys" ]; then
            echo "Refusing to include host .ssh/authorized_keys (would overwrite VM SSH key)" >&2
            return 1
        fi

        prefix=""
        IFS='/' read -ra parts <<< "$include_path"
        last_idx=$((${#parts[@]} - 1))
        for ((idx = 0; idx < last_idx; idx++)); do
            part="${parts[$idx]}"
            [ -n "$part" ] || continue
            prefix="$prefix/$part"
            HOME_RSYNC_ARGS+=("--include=$prefix/")
        done
        HOME_RSYNC_ARGS+=("--include=/$include_path" "--include=/$include_path/***")
    done

    local entry
    for entry in "${HOME_SECRET_DENYLIST[@]}"; do
        HOME_RSYNC_ARGS+=("--exclude=$entry")
        if [[ "$entry" == /* ]]; then
            HOME_RSYNC_ARGS+=("--exclude=$entry/**")
        fi
    done

    if [ "$full_copy" != "1" ]; then
        for entry in "${HOME_DEFAULT_EXCLUDES[@]}"; do
            HOME_RSYNC_ARGS+=("--exclude=$entry")
            if [[ "$entry" == /* ]]; then
                HOME_RSYNC_ARGS+=("--exclude=$entry/**")
            fi
        done
    fi
}

usage() {
    cat <<EOF
fcbox - Firecracker Arch Linux MicroVM (Distrobox replacement)

Usage:
  fcbox init-base                         Build Arch Linux base image (requires sudo/root)
  fcbox create <name> [--copy-home] [--home-full] [--include <path>] [--mem MB] [--vcpu N]
  fcbox enter <name> [--waypipe]          Start VM if stopped and open interactive shell
  fcbox run <name> -- <cmd...>            Run a command inside the VM
  fcbox sync-home <name> [--home-full] [--include <path>]
                                          One-way rsync of host \$HOME into isolated VM \$HOME
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
    local -A used_ids=()
    local config_file used candidate
    if [ -d "$BASE_DIR" ]; then
        for config_file in "$BASE_DIR"/*/config.env; do
            [ -f "$config_file" ] || continue
            used="$(grep -E '^VM_ID=' "$config_file" | cut -d= -f2- || true)"
            if [[ "$used" =~ ^[0-9]+$ ]] && [ "$((10#$used))" -ge 10 ] && [ "$((10#$used))" -le 254 ]; then
                used_ids["$((10#$used))"]=1
            fi
        done
    fi
    candidate=10
    while [ "$candidate" -le 254 ]; do
        if [ -z "${used_ids[$candidate]:-}" ]; then
            echo "$candidate"
            return 0
        fi
        candidate=$((candidate + 1))
    done
    echo "No available VM IP octets in ${FCBOX_SUBNET_IP_PREFIX}.10.10-254 (maximum 254 reached)" >&2
    return 1
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
    shift 2
    local stage
    stage="$(mktemp -d /var/tmp/fcbox-home-stage.XXXXXX)"
    CLEANUP_PATHS+=("$stage")

    build_home_rsync_args "$full_copy" "$@"

    echo "Copying \$HOME into isolated ext4 volume..."
    rsync -a --delete "${HOME_RSYNC_ARGS[@]}" "$HOME/" "$stage/"
    mke2fs -t ext4 -d "$stage" -L fcbox-home -m 1 "$home_img" "$FCBOX_HOME_SIZE" >/dev/null
    chmod 0660 "$home_img"
    rm -rf "$stage"
}

cmd="${1:-help}"
shift || true

case "$cmd" in
    init-base)
        exec sudo "$FCBOX_BUILD_ARCH_BASE_BIN" "$@"
        ;;
    create)
        NAME="${1:?Missing VM name}"
        validate_vm_name "$NAME"
        shift
        COPY_HOME=0
        FULL_HOME=0
        HOME_INCLUDES=()
        VM_MEM="$FCBOX_DEFAULT_MEM"
        VM_VCPU="$FCBOX_DEFAULT_VCPU"

        while [ $# -gt 0 ]; do
            case "$1" in
                --copy-home) COPY_HOME=1 ;;
                --home-full) COPY_HOME=1; FULL_HOME=1 ;;
                --include) shift; HOME_INCLUDES+=("${1:?Missing value for --include}") ;;
                --mem) shift; VM_MEM="${1:?Missing value for --mem}" ;;
                --vcpu) shift; VM_VCPU="${1:?Missing value for --vcpu}" ;;
                *) echo "Unknown option: $1" >&2; exit 1 ;;
            esac
            shift
        done

        if [ "${#HOME_INCLUDES[@]}" -gt 0 ] && [ "$COPY_HOME" != "1" ]; then
            echo "--include requires --copy-home or --home-full" >&2
            exit 1
        fi

        if [[ ! "$VM_MEM" =~ ^[1-9][0-9]*$ ]]; then
            echo "Invalid --mem value '$VM_MEM': must be a positive integer" >&2
            exit 1
        fi
        if [[ ! "$VM_VCPU" =~ ^[1-9][0-9]*$ ]]; then
            echo "Invalid --vcpu value '$VM_VCPU': must be a positive integer" >&2
            exit 1
        fi

        if [ ! -f "$FCBOX_BASE_IMAGE_PATH" ]; then
            echo "Arch base image not found at $FCBOX_BASE_IMAGE_PATH. Run: fcbox init-base" >&2
            exit 1
        fi

        ensure_ssh_key

        LOCK_FILE="$BASE_DIR/.lock"
        exec 9>>"$LOCK_FILE"
        chmod 0660 "$LOCK_FILE" 2>/dev/null || true
        flock -x 9

        VM_DIR="$BASE_DIR/$NAME"
        if [ -d "$VM_DIR" ]; then
            echo "fcbox '$NAME' already exists at $VM_DIR" >&2
            exit 1
        fi

        VM_ID="$(next_ip_octet)"
        if [ "$VM_ID" -gt 254 ]; then
            echo "Allocated VM_ID '$VM_ID' exceeds maximum allowed octet 254" >&2
            exit 1
        fi
        VM_IP="${FCBOX_SUBNET_IP_PREFIX}.10.$VM_ID/${FCBOX_SUBNET_PREFIX_LENGTH}"
        VM_HOST_IP="${FCBOX_SUBNET_IP_PREFIX}.10.$VM_ID"
        HEX_ID="$(printf '%02x' "$VM_ID")"
        VM_MAC="02:fc:00:00:10:$HEX_ID"
        VM_TAP="vm-fc$VM_ID"
        PUBKEY_B64="$(base64 -w0 "$SSH_KEY.pub")"

        mkdir -p "$VM_DIR"
        chmod 2775 "$VM_DIR"
        truncate -s "$FCBOX_OVERLAY_SIZE" "$VM_DIR/overlay.ext4"
        mkfs.ext4 -q -L fcbox-ovl "$VM_DIR/overlay.ext4"
        chmod 0660 "$VM_DIR/overlay.ext4"

        if [ "$COPY_HOME" = "1" ]; then
            stage_home_image "$VM_DIR/home.ext4" "$FULL_HOME" "${HOME_INCLUDES[@]}"
        else
            truncate -s "$FCBOX_HOME_SIZE" "$VM_DIR/home.ext4"
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
        chmod 0640 "$VM_DIR/config.env"
        flock -u 9
        exec 9>&-
        echo "Created fcbox '$NAME' ($VM_HOST_IP, copy-home=$COPY_HOME)"
        ;;
    enter)
        NAME="${1:?Missing VM name}"
        validate_vm_name "$NAME"
        shift
        USE_WAYPIPE=0
        if [ "${1:-}" = "--waypipe" ]; then
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
        NAME="${1:?Missing VM name}"
        validate_vm_name "$NAME"
        shift
        [ "${1:-}" = "--" ] && shift
        VM_DIR="$BASE_DIR/$NAME"
        load_vm_config "$VM_DIR/config.env"
        systemctl start "fcbox@$NAME.service"
        wait_ssh "$NAME" "$VM_HOST_IP" "$VM_USER"
        exec ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null "$VM_USER@$VM_HOST_IP" "$@"
        ;;
    sync-home)
        NAME="${1:?Missing VM name}"
        validate_vm_name "$NAME"
        shift
        FULL_HOME=0
        HOME_INCLUDES=()
        while [ $# -gt 0 ]; do
            case "$1" in
                --home-full) FULL_HOME=1 ;;
                --include) shift; HOME_INCLUDES+=("${1:?Missing value for --include}") ;;
                *) echo "Unknown option: $1" >&2; exit 1 ;;
            esac
            shift
        done
        VM_DIR="$BASE_DIR/$NAME"
        load_vm_config "$VM_DIR/config.env"
        build_home_rsync_args "$FULL_HOME" "${HOME_INCLUDES[@]}"
        systemctl start "fcbox@$NAME.service"
        wait_ssh "$NAME" "$VM_HOST_IP" "$VM_USER"
        exec rsync -av "${HOME_RSYNC_ARGS[@]}" \
            -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
            "$HOME/" "$VM_USER@$VM_HOST_IP:/home/$VM_USER/"
        ;;
    pull)
        NAME="${1:?Missing VM name}"
        validate_vm_name "$NAME"
        SRC="${2:?Missing remote path}"
        DST="${3:?Missing local destination}"
        VM_DIR="$BASE_DIR/$NAME"
        load_vm_config "$VM_DIR/config.env"
        wait_ssh "$NAME" "$VM_HOST_IP" "$VM_USER"
        exec rsync -av \
            -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
            "$VM_USER@$VM_HOST_IP:$SRC" "$DST"
        ;;
    reset)
        NAME="${1:?Missing VM name}"
        validate_vm_name "$NAME"
        systemctl start "fcbox-reset@$NAME.service"
        echo "Reset root overlay for '$NAME' (isolated home.ext4 preserved)."
        ;;
    stop)
        NAME="${1:?Missing VM name}"
        validate_vm_name "$NAME"
        exec systemctl stop "fcbox@$NAME.service"
        ;;
    rm)
        NAME="${1:?Missing VM name}"
        validate_vm_name "$NAME"
        systemctl stop "fcbox@$NAME.service" || true
        rm -rf "${BASE_DIR:?}/${NAME:?}"
        echo "Removed fcbox '$NAME'."
        ;;
    list)
        if [ -d "$BASE_DIR" ]; then
            for directory in "$BASE_DIR"/*; do
                [ -f "$directory/config.env" ] || continue
                name="$(basename "$directory")"
                validate_vm_name "$name" || continue
                load_vm_config "$directory/config.env" || continue
                state="$(systemctl is-active "fcbox@$name.service" 2>/dev/null || true)"
                printf '%-20s %-16s %-10s\n' "$name" "$VM_HOST_IP" "$state"
            done
        fi
        ;;
    *)
        usage
        ;;
esac
