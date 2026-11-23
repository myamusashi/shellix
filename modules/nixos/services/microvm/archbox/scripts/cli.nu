use common.nu *

const SELF_FILE = path self
const BASE_DIR = "/var/lib/microvms/archbox"

# Always excluded from VM home images and sync-home, even with --home-full.
const HOME_SECRET_DENYLIST = [
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
]

const HOME_DEFAULT_EXCLUDES = [
    "/.cache"
    "/.local/share/Trash"
    "/.local/share/Steam"
    "*.qcow2"
]

def ssh-key-dir []: nothing -> string {
    $"($env.HOME)/.local/share/fcbox"
}

def ssh-key-path []: nothing -> string {
    $"($env.HOME)/.local/share/fcbox/id_ed25519"
}

def usage [] {
    print r#'fcbox - Firecracker Arch Linux MicroVM (Distrobox replacement)

Usage:
  fcbox init-base                         Build Arch Linux base image (requires sudo/root)
  fcbox create <name> [--copy-home] [--home-full] [--include <path>] [--mem MB] [--vcpu N]
  fcbox enter <name> [--waypipe]          Start VM if stopped and open interactive shell
  fcbox run <name> -- <cmd...>            Run a command inside the VM
  fcbox sync-home <name> [--home-full] [--include <path>]
                                          One-way rsync of host $HOME into isolated VM $HOME
  fcbox pull <name> <vm-path> <host-path> Copy files out of VM isolation
  fcbox reset <name>                      Wipe overlay.ext4 (keep isolated home.ext4)
  fcbox stop <name>                       Stop VM
  fcbox rm <name>                         Stop and delete VM state
  fcbox list                              List configured fcbox VMs'#
}

def build-home-rsync-args [
    full_copy: bool
    includes: list<string>
]: nothing -> list<string> {
    mut rsync_args = ["--exclude=/.ssh/authorized_keys"]

    for raw_path in $includes {
        mut include_path = $raw_path
        while ($include_path | str starts-with "./") {
            $include_path = ($include_path | str substring 2..)
        }
        $include_path = ($include_path | str trim --left --char '/')
        $include_path = ($include_path | str trim --right --char '/')

        if (
            ($include_path | is-empty)
            or $include_path == ".."
            or ($include_path | str starts-with "../")
            or ($include_path | str contains "/../")
            or ($include_path | str ends-with "/..")
        ) {
            error make --unspanned {
                msg: $"Invalid --include path '($raw_path)'"
            }
        }
        if $include_path == ".ssh/authorized_keys" {
            error make --unspanned {
                msg: "Refusing to include host .ssh/authorized_keys (would overwrite VM SSH key)"
            }
        }

        let parts = ($include_path | split row "/")
        let last_idx = (($parts | length) - 1)
        mut prefix = ""
        for idx in 0..<$last_idx {
            let part = ($parts | get $idx)
            if ($part | is-empty) {
                continue
            }
            $prefix = $"($prefix)/($part)"
            $rsync_args = ($rsync_args | append $"--include=($prefix)/")
        }
        $rsync_args = ($rsync_args | append [$"--include=/($include_path)" $"--include=/($include_path)/***"])
    }

    for entry in $HOME_SECRET_DENYLIST {
        $rsync_args = ($rsync_args | append $"--exclude=($entry)")
        if ($entry | str starts-with "/") {
            $rsync_args = ($rsync_args | append $"--exclude=($entry)/**")
        }
    }

    if not $full_copy {
        for entry in $HOME_DEFAULT_EXCLUDES {
            $rsync_args = ($rsync_args | append $"--exclude=($entry)")
            if ($entry | str starts-with "/") {
                $rsync_args = ($rsync_args | append $"--exclude=($entry)/**")
            }
        }
    }

    $rsync_args
}

def ensure-ssh-key [] {
    let key_dir = (ssh-key-dir)
    let key_path = (ssh-key-path)
    mkdir $key_dir
    ^chmod 700 $key_dir
    if not (($key_path | path exists) and (($key_path | path expand | path type) == "file")) {
        let host = ($env.HOSTNAME? | default (sys host | get hostname))
        ^ssh-keygen -t ed25519 -N "" -f $key_path -C $"fcbox@($host)" o> /dev/null
    }
}

def next-ip-octet [] {
    mut used_ids: list<int> = []
    if ($BASE_DIR | path exists) and (($BASE_DIR | path expand | path type) == "dir") {
        let entries = (try { ls -af $BASE_DIR | get name } catch { [] })
        for entry in $entries {
            let config_file = $"($entry)/config.env"
            if not (($config_file | path exists) and (($config_file | path expand | path type) == "file")) {
                continue
            }
            let vm_id_line = (
                try {
                    open --raw $config_file
                    | lines
                    | where { |line| $line | str starts-with "VM_ID=" }
                    | get -o 0
                } catch {
                    null
                }
            )
            if $vm_id_line != null {
                let used = ($vm_id_line | str substring 6..)
                if ($used =~ '^[0-9]+$') {
                    let num = ($used | into int)
                    if $num >= 10 and $num <= 254 {
                        $used_ids = ($used_ids | append $num)
                    }
                }
            }
        }
    }

    for candidate in 10..254 {
        if not ($candidate in $used_ids) {
            return $candidate
        }
    }

    error make --unspanned {
        msg: $"No available VM IP octets in ($env.FCBOX_SUBNET_IP_PREFIX).10.10-254 \(maximum 254 reached\)"
    }
}

def wait-ssh [name: string, ip: string, user: string] {
    let key_path = (ssh-key-path)
    mut attempts = 0
    loop {
        let res = (
            do {
                ^ssh -i $key_path -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=1 $"($user)@($ip)" true
            } | complete
        )
        if $res.exit_code == 0 {
            return
        }
        if (do { ^systemctl is-active --quiet $"fcbox@($name).service" } | complete).exit_code != 0 {
            error make --unspanned {
                msg: $"fcbox@($name).service exited before SSH became ready. Check: journalctl -u fcbox@($name).service -n 50"
            }
        }
        $attempts = $attempts + 1
        if $attempts >= 60 {
            error make --unspanned {
                msg: $"Timed out waiting for SSH on ($ip)"
            }
        }
        sleep 500ms
    }
}

def stage-home-image [
    home_img: string
    full_copy: bool
    includes: list<string>
] {
    let stage = (^mktemp -d /var/tmp/fcbox-home-stage.XXXXXX | str trim)
    try {
        let rsync_args = (build-home-rsync-args $full_copy $includes)
        print 'Copying $HOME into isolated ext4 volume...'
        ^rsync -a --delete ...$rsync_args $"($env.HOME)/" $"($stage)/"
        ^mke2fs -q -t ext4 -d $stage -L fcbox-home -m 1 $home_img $env.FCBOX_HOME_SIZE o> /dev/null
        ^chmod 0660 $home_img
    } finally {
        rm -rf $stage
    }
}

def require-arg [args: list<string>, index: int, message: string]: nothing -> string {
    let value = ($args | get -o $index)
    if $value == null or ($value | is-empty) {
        error make --unspanned { msg: $message }
    }
    $value
}

def cmd-create [args: list<string>] {
    let name = (require-arg $args 0 "Missing VM name")
    validate-vm-name $name

    mut copy_home = false
    mut full_home = false
    mut home_includes: list<string> = []
    mut vm_mem = $env.FCBOX_DEFAULT_MEM
    mut vm_vcpu = $env.FCBOX_DEFAULT_VCPU

    mut idx = 1
    let count = ($args | length)
    while $idx < $count {
        let flag = ($args | get $idx)
        match $flag {
            "--copy-home" => { $copy_home = true }
            "--home-full" => {
                $copy_home = true
                $full_home = true
            }
            "--include" => {
                $idx = $idx + 1
                let val = (require-arg $args $idx "Missing value for --include")
                $home_includes = ($home_includes | append $val)
            }
            "--mem" => {
                $idx = $idx + 1
                $vm_mem = (require-arg $args $idx "Missing value for --mem")
            }
            "--vcpu" => {
                $idx = $idx + 1
                $vm_vcpu = (require-arg $args $idx "Missing value for --vcpu")
            }
            _ => {
                error make --unspanned { msg: $"Unknown option: ($flag)" }
            }
        }
        $idx = $idx + 1
    }

    if ($home_includes | is-not-empty) and not $copy_home {
        error make --unspanned { msg: "--include requires --copy-home or --home-full" }
    }
    if not ($vm_mem =~ '^[1-9][0-9]*$') {
        error make --unspanned {
            msg: $"Invalid --mem value '($vm_mem)': must be a positive integer"
        }
    }
    if not ($vm_vcpu =~ '^[1-9][0-9]*$') {
        error make --unspanned {
            msg: $"Invalid --vcpu value '($vm_vcpu)': must be a positive integer"
        }
    }

    let base_img = $env.FCBOX_BASE_IMAGE_PATH
    if not (($base_img | path exists) and (($base_img | path expand | path type) == "file")) {
        error make --unspanned {
            msg: $"Arch base image not found at ($base_img). Run: fcbox init-base"
        }
    }

    ensure-ssh-key

    let lock_file = $"($BASE_DIR)/.lock"
    let _ = (do { ^touch $lock_file } | complete)
    let _ = (do { ^chmod 0660 $lock_file } | complete)

    let payload = ({
        name: $name
        copy_home: $copy_home
        full_home: $full_home
        home_includes: $home_includes
        vm_mem: $vm_mem
        vm_vcpu: $vm_vcpu
    } | to json -r)

    ^flock -x $lock_file $nu.current-exe --no-config-file $SELF_FILE _create-locked $payload
}

def cmd-create-locked [args: list<string>] {
    let payload_json = (require-arg $args 0 "Missing internal payload")
    let p = ($payload_json | from json)
    let name = $p.name
    validate-vm-name $name

    let vm_dir = $"($BASE_DIR)/($name)"
    if ($vm_dir | path exists) and (($vm_dir | path expand | path type) == "dir") {
        error make --unspanned {
            msg: $"fcbox '($name)' already exists at ($vm_dir)"
        }
    }

    let vm_id = (next-ip-octet)
    if $vm_id > 254 {
        error make --unspanned {
            msg: $"Allocated VM_ID '($vm_id)' exceeds maximum allowed octet 254"
        }
    }

    let vm_ip = $"($env.FCBOX_SUBNET_IP_PREFIX).10.($vm_id)/($env.FCBOX_SUBNET_PREFIX_LENGTH)"
    let vm_host_ip = $"($env.FCBOX_SUBNET_IP_PREFIX).10.($vm_id)"
    let hex_id = ($vm_id | format number | get lowerhex | str substring 2.. | fill -a right -c "0" -w 2)
    let vm_mac = $"02:fc:00:00:10:($hex_id)"
    let vm_tap = $"vm-fc($vm_id)"
    let pubkey_b64 = (open --raw $"(ssh-key-path).pub" | encode base64)

    mkdir $vm_dir
    ^chmod 2775 $vm_dir

    let overlay_img = $"($vm_dir)/overlay.ext4"
    ^truncate -s $env.FCBOX_OVERLAY_SIZE $overlay_img
    ^mkfs.ext4 -q -L fcbox-ovl $overlay_img
    ^chmod 0660 $overlay_img

    let home_img = $"($vm_dir)/home.ext4"
    if $p.copy_home {
        stage-home-image $home_img $p.full_home $p.home_includes
    } else {
        ^truncate -s $env.FCBOX_HOME_SIZE $home_img
        ^mkfs.ext4 -q -L fcbox-home $home_img
        ^chmod 0660 $home_img
    }

    let vm_user = ($env.USER? | default (^id -un | str trim))
    let owner_uid = (^id -u | str trim)
    let owner_gid = (^id -g | str trim)

    let config_content = ([
        $"VM_ID=($vm_id)"
        $"VM_IP=($vm_ip)"
        $"VM_HOST_IP=($vm_host_ip)"
        $"VM_MAC=($vm_mac)"
        $"VM_TAP=($vm_tap)"
        $"VM_MEM=($p.vm_mem)"
        $"VM_VCPU=($p.vm_vcpu)"
        $"VM_USER=($vm_user)"
        $"VM_OWNER_UID=($owner_uid)"
        $"VM_OWNER_GID=($owner_gid)"
        $"VM_PUBKEY_B64=($pubkey_b64)"
    ] | str join "\n") + "\n"

    let config_file = $"($vm_dir)/config.env"
    $config_content | save -f $config_file
    ^chmod 0640 $config_file

    let copy_home_flag = if $p.copy_home { "1" } else { "0" }
    print $"Created fcbox '($name)' \(($vm_host_ip), copy-home=($copy_home_flag)\)"
}

def cmd-enter [args: list<string>] {
    let name = (require-arg $args 0 "Missing VM name")
    validate-vm-name $name

    mut rest = ($args | skip 1)
    mut use_waypipe = false
    if (($rest | get -o 0) == "--waypipe") {
        $use_waypipe = true
        $rest = ($rest | skip 1)
    }

    let vm = (load-vm-config $"($BASE_DIR)/($name)/config.env")
    ^systemctl start $"fcbox@($name).service"
    wait-ssh $name $vm.host_ip $vm.user

    let ssh_args = ([
        "-i" (ssh-key-path)
        "-o" "StrictHostKeyChecking=no"
        "-o" "UserKnownHostsFile=/dev/null"
        $"($vm.user)@($vm.host_ip)"
    ] | append $rest)

    if $use_waypipe {
        exec waypipe ssh ...$ssh_args
    } else if (which kitten | is-not-empty) {
        exec kitten ssh ...$ssh_args
    } else {
        exec ssh ...$ssh_args
    }
}

def cmd-run [args: list<string>] {
    let name = (require-arg $args 0 "Missing VM name")
    validate-vm-name $name

    mut rest = ($args | skip 1)
    if (($rest | get -o 0) == "--") {
        $rest = ($rest | skip 1)
    }

    let vm = (load-vm-config $"($BASE_DIR)/($name)/config.env")
    ^systemctl start $"fcbox@($name).service"
    wait-ssh $name $vm.host_ip $vm.user

    let ssh_args = ([
        "-i" (ssh-key-path)
        "-o" "StrictHostKeyChecking=no"
        "-o" "UserKnownHostsFile=/dev/null"
        $"($vm.user)@($vm.host_ip)"
    ] | append $rest)
    exec ssh ...$ssh_args
}

def cmd-sync-home [args: list<string>] {
    let name = (require-arg $args 0 "Missing VM name")
    validate-vm-name $name

    mut full_home = false
    mut home_includes: list<string> = []

    mut idx = 1
    let count = ($args | length)
    while $idx < $count {
        let flag = ($args | get $idx)
        match $flag {
            "--home-full" => { $full_home = true }
            "--include" => {
                $idx = $idx + 1
                let val = (require-arg $args $idx "Missing value for --include")
                $home_includes = ($home_includes | append $val)
            }
            _ => {
                error make --unspanned { msg: $"Unknown option: ($flag)" }
            }
        }
        $idx = $idx + 1
    }

    let vm = (load-vm-config $"($BASE_DIR)/($name)/config.env")
    let rsync_args = (build-home-rsync-args $full_home $home_includes)
    ^systemctl start $"fcbox@($name).service"
    wait-ssh $name $vm.host_ip $vm.user

    let rsh_cmd = $"ssh -i (ssh-key-path) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    let exec_args = (["-av"] | append $rsync_args | append [
        "-e" $rsh_cmd
        $"($env.HOME)/"
        $"($vm.user)@($vm.host_ip):/home/($vm.user)/"
    ])
    exec rsync ...$exec_args
}

def cmd-pull [args: list<string>] {
    let name = (require-arg $args 0 "Missing VM name")
    validate-vm-name $name
    let src = (require-arg $args 1 "Missing remote path")
    let dst = (require-arg $args 2 "Missing local destination")

    let vm = (load-vm-config $"($BASE_DIR)/($name)/config.env")
    wait-ssh $name $vm.host_ip $vm.user

    let rsh_cmd = $"ssh -i (ssh-key-path) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    exec rsync -av -e $rsh_cmd $"($vm.user)@($vm.host_ip):($src)" $dst
}

def cmd-reset [args: list<string>] {
    let name = (require-arg $args 0 "Missing VM name")
    validate-vm-name $name
    ^systemctl start $"fcbox-reset@($name).service"
    print $"Reset root overlay for '($name)' \(isolated home.ext4 preserved\)."
}

def cmd-stop [args: list<string>] {
    let name = (require-arg $args 0 "Missing VM name")
    validate-vm-name $name
    exec systemctl stop $"fcbox@($name).service"
}

def cmd-rm [args: list<string>] {
    let name = (require-arg $args 0 "Missing VM name")
    validate-vm-name $name
    let _ = (do { ^systemctl stop $"fcbox@($name).service" } | complete)
    rm -rf $"($BASE_DIR)/($name)"
    print $"Removed fcbox '($name)'."
}

def cmd-list [] {
    if not (($BASE_DIR | path exists) and (($BASE_DIR | path expand | path type) == "dir")) {
        return
    }
    let entries = (try { ls -af $BASE_DIR | sort-by name | get name } catch { [] })
    for directory in $entries {
        let config_file = $"($directory)/config.env"
        if not (($config_file | path exists) and (($config_file | path expand | path type) == "file")) {
            continue
        }
        let name = ($directory | path basename)
        let vm = (try {
            validate-vm-name $name
            load-vm-config $config_file
        } catch {
            null
        })
        if $vm == null {
            continue
        }
        let state = (do { ^systemctl is-active $"fcbox@($name).service" } | complete | get stdout | str trim)
        print $"($name | fill -a left -w 20) ($vm.host_ip | fill -a left -w 16) ($state | fill -a left -w 10)"
    }
}

def --wrapped main [...args: string] {
    let cmd = ($args | get -o 0 | default "help")
    let rest = ($args | skip 1)

    match $cmd {
        "init-base" => { exec sudo $env.FCBOX_BUILD_ARCH_BASE_BIN ...$rest }
        "create" => { cmd-create $rest }
        "_create-locked" => { cmd-create-locked $rest }
        "enter" => { cmd-enter $rest }
        "run" => { cmd-run $rest }
        "sync-home" => { cmd-sync-home $rest }
        "pull" => { cmd-pull $rest }
        "reset" => { cmd-reset $rest }
        "stop" => { cmd-stop $rest }
        "rm" => { cmd-rm $rest }
        "list" => { cmd-list }
        _ => { usage }
    }
}
