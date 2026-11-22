# shellcheck shell=bash

validate_vm_name() {
    local candidate_name="$1"
    if [[ ! "$candidate_name" =~ ^[a-z0-9][a-z0-9-]{0,30}$ ]]; then
        echo "Invalid VM name '$candidate_name': must match ^[a-z0-9][a-z0-9-]{0,30}$" >&2
        return 1
    fi
}

jailer_uid_for_vm_id() {
    local vm_id="$1"
    if [[ ! "$vm_id" =~ ^[0-9]+$ ]] || [ "$((10#$vm_id))" -lt 2 ] || [ "$((10#$vm_id))" -gt 254 ]; then
        echo "Invalid VM_ID '$vm_id': must be an integer between 2 and 254" >&2
        return 1
    fi
    echo "$((20000 + 10#$vm_id))"
}

resolve_firecracker_binary() {
    local firecracker_bin="$1"
    readlink -f "$firecracker_bin"
}

stage_firecracker_libraries() {
    local firecracker_bin="$1"
    local jail_root="$2"
    local library_path
    for library_path in $(ldd "$firecracker_bin" | grep -o '/nix/store/[^ ]*'); do
        mkdir -p "$jail_root$(dirname "$library_path")"
        ln -f "$library_path" "$jail_root$library_path" 2>/dev/null \
            || cp -Lf "$library_path" "$jail_root$library_path"
    done
}

stage_kernel_into_jail() {
    local store_vmlinux="$1"
    local staged_kernel="$2"
    local jail_kernel="$3"
    local images_dir
    images_dir="$(dirname "$staged_kernel")"

    mkdir -p "$images_dir"
    if [ ! -f "$staged_kernel" ] || [ -L "$staged_kernel" ]; then
        local temp_kernel="$staged_kernel.tmp.$$"
        cp -f "$store_vmlinux" "$temp_kernel"
        chown root:root "$temp_kernel"
        chmod 0444 "$temp_kernel"
        mv -f "$temp_kernel" "$staged_kernel"

        # Remove older staged kernels; running jails keep their hardlinked inode alive.
        local old_kernel
        for old_kernel in "$images_dir"/vmlinux-*; do
            [ -e "$old_kernel" ] || continue
            case "$old_kernel" in
                "$staged_kernel"|*.tmp.*) continue ;;
                *) rm -f "$old_kernel" ;;
            esac
        done
    fi

    if ! ln -f "$staged_kernel" "$jail_kernel" 2>/dev/null; then
        cp -f "$staged_kernel" "$jail_kernel"
        chown root:root "$jail_kernel"
        chmod 0444 "$jail_kernel"
    fi
}

common_boot_args() {
    printf '%s' "console=ttyS0,115200 reboot=k panic=1 random.trust_cpu=on i8042.noaux i8042.nomux i8042.nopnp i8042.dumbkbd"
}

write_vm_config_json() {
    local output_file="$1"
    local vcpu_count="$2"
    local mem_size_mib="$3"
    local boot_args="$4"
    local drives_json="$5"
    local tap_name="$6"
    local guest_mac="$7"
    local owner_uid="$8"

    jq -n \
        --argjson vcpu "$vcpu_count" \
        --argjson mem "$mem_size_mib" \
        --arg boot_args "$boot_args" \
        --argjson drives "$drives_json" \
        --arg tap "$tap_name" \
        --arg mac "$guest_mac" \
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
            "drives": $drives,
            "network-interfaces": [
                {
                    "iface_id": $tap,
                    "host_dev_name": $tap,
                    "guest_mac": $mac
                }
            ]
        }' > "$output_file"
    chown "$owner_uid:$owner_uid" "$output_file"
    chmod 0400 "$output_file"
}

validate_ipv4_address() {
    local address="$1"
    if [[ ! "$address" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
        return 1
    fi
    local octet
    for octet in "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"; do
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
    local address="${BASH_REMATCH[1]}"
    local prefix="${BASH_REMATCH[2]}"
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
        count="$(grep -cE "^${key}=" "$config_file" || true)"
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

    if [[ ! "$VM_ID" =~ ^[0-9]+$ ]] || [ "$((10#$VM_ID))" -lt 10 ] || [ "$((10#$VM_ID))" -gt 254 ]; then
        echo "Invalid VM_ID '$VM_ID' in '$config_file' (must be 10..254)" >&2
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
