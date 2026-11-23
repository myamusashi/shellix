use common.nu *

def main [vm_name: string] {
    validate-vm-name $vm_name

    let state_dir = $"/var/lib/microvms/archbox/($vm_name)"
    let vm = (load-vm-config $"($state_dir)/config.env")
    let jailer_uid = (jailer-uid-for-vm-id $vm.id)
    let firecracker_bin = (resolve-firecracker-binary $env.FCBOX_FIRECRACKER_BIN)

    # RLIMIT_FSIZE applies to pwrite offsets on existing sparse ext4 images.
    let overlay_size = (^stat -c '%s' $"($state_dir)/overlay.ext4" | str trim | into int)
    let home_size = (^stat -c '%s' $"($state_dir)/home.ext4" | str trim | into int)
    let fsize_bytes = ([$overlay_size $home_size 67108864] | math max)

    let mem_max_bytes = (($vm.mem + 256) * 1024 * 1024)
    let cpu_quota_us = ($vm.vcpu * 100000)

    let cgroup_line = (
        open --raw /proc/self/cgroup
        | lines
        | where { |line| $line | str starts-with "0::/" }
        | get -o 0
        | default ""
    )
    let self_cgroup = if ($cgroup_line | str starts-with "0::") {
        $cgroup_line | str substring 3..
    } else {
        ""
    }
    let trimmed_cgroup = ($self_cgroup | str trim --left --char '/')
    if not ($trimmed_cgroup | str ends-with "/jailer_launcher") {
        error make --unspanned {
            msg: $"Expected fcbox-run to execute inside systemd DelegateSubgroup 'jailer_launcher' \(got cgroup '($self_cgroup)'\)"
        }
    }
    let parent_cgroup = ($trimmed_cgroup | str replace -r '/jailer_launcher$' '')
    if ($parent_cgroup | is-empty) {
        error make --unspanned {
            msg: $"Expected fcbox-run to execute inside systemd DelegateSubgroup 'jailer_launcher' \(got cgroup '($self_cgroup)'\)"
        }
    }

    let jailer_args = [
        "--id" $vm_name
        "--exec-file" $firecracker_bin
        "--uid" ($jailer_uid | into string)
        "--gid" ($jailer_uid | into string)
        "--chroot-base-dir" "/srv/jailer"
        "--new-pid-ns"
        "--resource-limit" "no-file=1024"
        "--resource-limit" $"fsize=($fsize_bytes)"
        "--cgroup-version" "2"
        "--parent-cgroup" $parent_cgroup
        "--cgroup" $"memory.max=($mem_max_bytes)"
        "--cgroup" $"cpu.max=($cpu_quota_us) 100000"
        "--"
        "--enable-pci"
        "--config-file" "vm.json"
        "--api-sock" "control.socket"
    ]
    exec $env.FCBOX_JAILER_BIN ...$jailer_args
}
