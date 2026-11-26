use common.nu *

def main [vm_name: string] {
    validate-vm-name $vm_name

    let state_dir = $"/var/lib/microvms/archbox/($vm_name)"
    if ($state_dir | path type) != "dir" {
        error make --unspanned {
            msg: $"Invalid state directory '($state_dir)'"
        }
    }

    let config_file = $"($state_dir)/config.env"
    if not ($config_file | path exists) {
        error make --unspanned {
            msg: $"Missing ($config_file) for archbox '($vm_name)'"
        }
    }

    let vm = (load-vm-config $config_file)
    if (do { ^systemctl is-active --quiet $"fcbox@($vm_name).service" } | complete).exit_code == 0 {
        error make --unspanned {
            msg: $"Refusing to reset overlay while fcbox@($vm_name).service is active"
        }
    }

    let jailer_uid = (jailer-uid-for-vm-id $vm.id)
    let overlay_path = $"($state_dir)/overlay.ext4"

    rm -f $overlay_path
    ^truncate -s $env.FCBOX_OVERLAY_SIZE $overlay_path
    ^mkfs.ext4 -q -F -L fcbox-ovl $overlay_path
    ^chown $"($jailer_uid):($jailer_uid)" $overlay_path
    ^chmod 0600 $overlay_path
}
