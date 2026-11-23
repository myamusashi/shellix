const CONFIG_KEYS = [
    "VM_ID"
    "VM_IP"
    "VM_HOST_IP"
    "VM_MAC"
    "VM_TAP"
    "VM_MEM"
    "VM_VCPU"
    "VM_USER"
    "VM_OWNER_UID"
    "VM_OWNER_GID"
    "VM_PUBKEY_B64"
]

const ALLOWED_CONFIG_LINE_PATTERN = '^(VM_ID|VM_IP|VM_HOST_IP|VM_MAC|VM_TAP|VM_MEM|VM_VCPU|VM_USER|VM_OWNER_UID|VM_OWNER_GID|VM_PUBKEY_B64)='

export def validate-vm-name [candidate_name: string] {
    if not ($candidate_name =~ '^[a-z0-9][a-z0-9-]{0,30}$') {
        error make --unspanned {
            msg: $"Invalid VM name '($candidate_name)': must match ^[a-z0-9][a-z0-9-]{0,30}$"
        }
    }
}

export def jailer-uid-for-vm-id [vm_id: any]: nothing -> int {
    let id_str = ($vm_id | into string)
    if not ($id_str =~ '^[0-9]+$') {
        error make --unspanned {
            msg: $"Invalid VM_ID '($id_str)': must be an integer between 2 and 254"
        }
    }
    let id = ($id_str | into int)
    if $id < 2 or $id > 254 {
        error make --unspanned {
            msg: $"Invalid VM_ID '($id_str)': must be an integer between 2 and 254"
        }
    }
    20000 + $id
}

export def resolve-firecracker-binary [firecracker_bin: string]: nothing -> string {
    ^readlink -f $firecracker_bin | str trim
}

export def stage-firecracker-libraries [
    firecracker_bin: string
    jail_root: string
] {
    let libs = (
        ^ldd $firecracker_bin
        | split row -r '\s+'
        | where { |token| $token | str starts-with "/nix/store/" }
        | uniq
    )
    for library_path in $libs {
        let target_path = $"($jail_root)($library_path)"
        mkdir ($target_path | path dirname)
        let linked = (do { ^ln -f $library_path $target_path } | complete)
        if $linked.exit_code != 0 {
            ^cp -Lf $library_path $target_path
        }
    }
}

export def stage-kernel-into-jail [
    store_vmlinux: string
    staged_kernel: string
    jail_kernel: string
] {
    let images_dir = ($staged_kernel | path dirname)
    mkdir $images_dir
    if ($staged_kernel | path type) != "file" {
        let temp_kernel = $"($staged_kernel).tmp.($nu.pid)"
        ^cp -f $store_vmlinux $temp_kernel
        ^chown root:root $temp_kernel
        ^chmod 0444 $temp_kernel
        ^mv -f $temp_kernel $staged_kernel

        # Remove older staged kernels; running jails keep their hardlinked inode alive.
        let staged_base = ($staged_kernel | path basename)
        for entry in (ls -af $images_dir | get name) {
            let base = ($entry | path basename)
            if not ($base | str starts-with "vmlinux-") {
                continue
            }
            if $base == $staged_base or ($base | str contains ".tmp.") {
                continue
            }
            rm -f $entry
        }
    }

    let linked = (do { ^ln -f $staged_kernel $jail_kernel } | complete)
    if $linked.exit_code != 0 {
        ^cp -f $staged_kernel $jail_kernel
        ^chown root:root $jail_kernel
        ^chmod 0444 $jail_kernel
    }
}

export def common-boot-args []: nothing -> string {
    "console=ttyS0,115200 reboot=k panic=1 random.trust_cpu=on i8042.noaux i8042.nomux i8042.nopnp i8042.dumbkbd"
}

export def write-vm-config-json [
    output_file: string
    vcpu_count: int
    mem_size_mib: int
    boot_args: string
    drives: list<record>
    tap_name: string
    guest_mac: string
    owner_uid: int
] {
    {
        "boot-source": {
            kernel_image_path: "vmlinux"
            initrd_path: "initrd"
            boot_args: $boot_args
        }
        "machine-config": {
            vcpu_count: $vcpu_count
            mem_size_mib: $mem_size_mib
            smt: true
        }
        entropy: {}
        drives: $drives
        "network-interfaces": [
            {
                iface_id: $tap_name
                host_dev_name: $tap_name
                guest_mac: $guest_mac
            }
        ]
    }
    | to json --indent 2
    | save -f $output_file

    ^chown $"($owner_uid):($owner_uid)" $output_file
    ^chmod 0400 $output_file
}

export def is-valid-ipv4-address [address: string]: nothing -> bool {
    let matched = ($address | parse -r '^(?P<o1>[0-9]{1,3})\.(?P<o2>[0-9]{1,3})\.(?P<o3>[0-9]{1,3})\.(?P<o4>[0-9]{1,3})$')
    if ($matched | is-empty) {
        return false
    }
    let row = ($matched | first)
    [$row.o1 $row.o2 $row.o3 $row.o4] | all { |octet| ($octet | into int) <= 255 }
}

export def is-valid-ipv4-cidr [cidr: string]: nothing -> bool {
    let matched = ($cidr | parse -r '^(?P<address>[0-9.]+)/(?P<prefix>[0-9]{1,2})$')
    if ($matched | is-empty) {
        return false
    }
    let row = ($matched | first)
    (is-valid-ipv4-address $row.address) and (($row.prefix | into int) <= 32)
}

export def load-vm-config [config_file: string]: nothing -> record {
    if ($config_file | path type) != "file" {
        error make --unspanned {
            msg: $"Config file '($config_file)' must exist as a regular file"
        }
    }

    let file_lines = (open --raw $config_file | lines)
    let bad_lines = (
        $file_lines
        | enumerate
        | where { |row| not ($row.item =~ $ALLOWED_CONFIG_LINE_PATTERN) }
        | each { |row| $"($row.index + 1):($row.item)" }
    )
    if ($bad_lines | is-not-empty) {
        let details = ($bad_lines | str join "\n")
        error make --unspanned {
            msg: $"Malformed or disallowed entries in '($config_file)':\n($details)"
        }
    }

    mut values: record = {}
    for key in $CONFIG_KEYS {
        let prefix = $"($key)="
        let matching = ($file_lines | where { |line| $line | str starts-with $prefix })
        let count = ($matching | length)
        if $count != 1 {
            error make --unspanned {
                msg: $"Config file '($config_file)' must contain exactly one '($key)' entry \(found ($count)\)"
            }
        }
        let val = (($matching | first) | split row -n 2 "=" | get 1)
        $values = ($values | upsert $key $val)
    }

    if not ($values.VM_ID =~ '^[0-9]+$') {
        error make --unspanned {
            msg: $"Invalid VM_ID '($values.VM_ID)' in '($config_file)' \(must be 10..254\)"
        }
    }
    let vm_id = ($values.VM_ID | into int)
    if $vm_id < 10 or $vm_id > 254 {
        error make --unspanned {
            msg: $"Invalid VM_ID '($values.VM_ID)' in '($config_file)' \(must be 10..254\)"
        }
    }

    if not (is-valid-ipv4-cidr $values.VM_IP) {
        error make --unspanned {
            msg: $"Invalid VM_IP '($values.VM_IP)' in '($config_file)'"
        }
    }
    if not (is-valid-ipv4-address $values.VM_HOST_IP) {
        error make --unspanned {
            msg: $"Invalid VM_HOST_IP '($values.VM_HOST_IP)' in '($config_file)'"
        }
    }
    if not ($values.VM_MAC =~ '^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$') {
        error make --unspanned {
            msg: $"Invalid VM_MAC '($values.VM_MAC)' in '($config_file)'"
        }
    }
    if not ($values.VM_TAP =~ '^vm-fc[0-9]{1,3}$') {
        error make --unspanned {
            msg: $"Invalid VM_TAP '($values.VM_TAP)' in '($config_file)'"
        }
    }
    if not ($values.VM_MEM =~ '^[1-9][0-9]*$') {
        error make --unspanned {
            msg: $"Invalid VM_MEM '($values.VM_MEM)' in '($config_file)'"
        }
    }
    if not ($values.VM_VCPU =~ '^[1-9][0-9]*$') {
        error make --unspanned {
            msg: $"Invalid VM_VCPU '($values.VM_VCPU)' in '($config_file)'"
        }
    }
    if not ($values.VM_USER =~ '^[a-z_][a-z0-9_-]*$') {
        error make --unspanned {
            msg: $"Invalid VM_USER '($values.VM_USER)' in '($config_file)'"
        }
    }
    if not ($values.VM_OWNER_UID =~ '^[0-9]+$') {
        error make --unspanned {
            msg: $"Invalid VM_OWNER_UID '($values.VM_OWNER_UID)' in '($config_file)'"
        }
    }
    if not ($values.VM_OWNER_GID =~ '^[0-9]+$') {
        error make --unspanned {
            msg: $"Invalid VM_OWNER_GID '($values.VM_OWNER_GID)' in '($config_file)'"
        }
    }
    if not ($values.VM_PUBKEY_B64 =~ '^[A-Za-z0-9+/]+={0,2}$') {
        error make --unspanned {
            msg: $"Invalid VM_PUBKEY_B64 in '($config_file)'"
        }
    }

    {
        id: $vm_id
        ip: $values.VM_IP
        host_ip: $values.VM_HOST_IP
        mac: $values.VM_MAC
        tap: $values.VM_TAP
        mem: ($values.VM_MEM | into int)
        vcpu: ($values.VM_VCPU | into int)
        user: $values.VM_USER
        owner_uid: ($values.VM_OWNER_UID | into int)
        owner_gid: ($values.VM_OWNER_GID | into int)
        pubkey_b64: $values.VM_PUBKEY_B64
    }
}

export def process-alive [pid: int]: nothing -> bool {
    (do { ^kill -0 ($pid | into string) } | complete).exit_code == 0
}
