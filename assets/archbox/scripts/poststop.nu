use common.nu *

def main [vm_name: string] {
    validate-vm-name $vm_name

    let state_dir = $"/var/lib/microvms/archbox/($vm_name)"
    let jail_dir = $"/srv/jailer/firecracker/($vm_name)"
    let config_file = $"($state_dir)/config.env"

    if ($config_file | path exists) {
        let vm = (load-vm-config $config_file)
        if ($vm.tap | is-not-empty) and (do { ^ip link show $vm.tap } | complete).exit_code == 0 {
            let _ = (do { ^ip link delete $vm.tap } | complete)
        }
    }

    rm -rf $jail_dir
}
