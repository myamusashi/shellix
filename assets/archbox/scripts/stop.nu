use common.nu *

def main [vm_name: string] {
    validate-vm-name $vm_name

    let jail_root = $"/srv/jailer/firecracker/($vm_name)/root"
    let sock = $"($jail_root)/control.socket"
    let pid_file = $"($jail_root)/firecracker.pid"

    mut target_pid = ($env.MAINPID? | default "" | str trim)
    if ($target_pid | is-empty) and ($pid_file | path type) == "file" {
        $target_pid = (try { open --raw $pid_file | str trim } catch { "" })
    }
    if not ($target_pid =~ '^[0-9]+$') {
        $target_pid = ""
    }

    if ($sock | path type) == "socket" {
        let _ = (
            do {
                ^curl -fsS --max-time 5 --unix-socket $sock -X PUT http://localhost/actions -d '{"action_type": "SendCtrlAltDel"}'
            } | complete
        )
    }

    # Wait up to 20s for Firecracker to exit cleanly before systemd sends SIGTERM.
    if ($target_pid | is-not-empty) {
        let pid = ($target_pid | into int)
        for _ in 0..<100 {
            if not (process-alive $pid) {
                return
            }
            sleep 200ms
        }
    }
}
