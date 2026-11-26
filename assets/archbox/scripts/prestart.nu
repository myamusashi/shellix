use common.nu *

def main [vm_name: string] {
    validate-vm-name $vm_name

    let state_dir = $"/var/lib/microvms/archbox/($vm_name)"
    let jail_root = $"/srv/jailer/firecracker/($vm_name)/root"
    let config_file = $"($state_dir)/config.env"
    let base_img = $env.FCBOX_BASE_IMAGE_PATH

    if not ($config_file | path exists) {
        error make --unspanned {
            msg: $"Missing ($config_file) for archbox '($vm_name)'"
        }
    }
    if not (($base_img | path exists) and (($base_img | path expand | path type) == "file")) {
        error make --unspanned {
            msg: $"Missing Arch base image at ($base_img). Run: sudo fcbox init-base"
        }
    }

    let vm = (load-vm-config $config_file)
    let jailer_uid = (jailer-uid-for-vm-id $vm.id)
    let firecracker_bin = (resolve-firecracker-binary $env.FCBOX_FIRECRACKER_BIN)

    if (do { ^ip link show $vm.tap } | complete).exit_code == 0 {
        ^ip link delete $vm.tap
    }
    ^ip tuntap add name $vm.tap mode tap user ($jailer_uid | into string) vnet_hdr
    ^ip link set $vm.tap master $env.FCBOX_BRIDGE_NAME
    ^ip link set $vm.tap up

    rm -rf $jail_root
    mkdir $jail_root
    ^chown $"($jailer_uid):($jailer_uid)" $"/srv/jailer/firecracker/($vm_name)" $jail_root
    stage-firecracker-libraries $firecracker_bin $jail_root

    stage-kernel-into-jail $env.FCBOX_VMLINUX_PATH $env.FCBOX_STAGED_KERNEL_PATH $"($jail_root)/vmlinux"
    ^cp -f $env.FCBOX_INITRD_FILE $"($jail_root)/initrd"
    ^chown root:root $"($jail_root)/initrd"
    ^chmod 0444 $"($jail_root)/initrd"

    # Keep the shared base image root:root 0444 without mutating the hardlinked inode.
    let base_linked = (do { ^ln -f $base_img $"($jail_root)/base.ext4" } | complete)
    if $base_linked.exit_code != 0 {
        ^cp -f $base_img $"($jail_root)/base.ext4"
        ^chown root:root $"($jail_root)/base.ext4"
        ^chmod 0444 $"($jail_root)/base.ext4"
    }

    if (do { ^ln -f $"($state_dir)/overlay.ext4" $"($jail_root)/overlay.ext4" } | complete).exit_code != 0 {
        error make --unspanned {
            msg: "overlay.ext4 must live on the same filesystem as /srv/jailer for hardlinking"
        }
    }
    if (do { ^ln -f $"($state_dir)/home.ext4" $"($jail_root)/home.ext4" } | complete).exit_code != 0 {
        error make --unspanned {
            msg: "home.ext4 must live on the same filesystem as /srv/jailer for hardlinking"
        }
    }

    ^chown $"($jailer_uid):($jailer_uid)" $"($jail_root)/overlay.ext4" $"($jail_root)/home.ext4"
    ^chmod 0600 $"($jail_root)/overlay.ext4" $"($jail_root)/home.ext4"

    let boot_args = $"(common-boot-args) fcbox.ip=($vm.ip) fcbox.gw=($env.FCBOX_GATEWAY_ADDRESS) fcbox.dns=($env.FCBOX_PRIMARY_NAMESERVER) fcbox.host=($vm_name) fcbox.user=($vm.user) fcbox.uid=($vm.owner_uid) fcbox.gid=($vm.owner_gid) fcbox.pubkey=($vm.pubkey_b64)"
    let drives = [
        {
            drive_id: "base"
            path_on_host: "base.ext4"
            is_root_device: false
            is_read_only: true
        }
        {
            drive_id: "overlay"
            path_on_host: "overlay.ext4"
            is_root_device: false
            is_read_only: false
            cache_type: "Writeback"
        }
        {
            drive_id: "home"
            path_on_host: "home.ext4"
            is_root_device: false
            is_read_only: false
            cache_type: "Writeback"
        }
    ]
    write-vm-config-json $"($jail_root)/vm.json" $vm.vcpu $vm.mem $boot_args $drives $vm.tap $vm.mac $jailer_uid
}
