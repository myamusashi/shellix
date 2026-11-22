{
    pkgs,
    kernelPackage,
    gatewayAddress,
    primaryNameserver,
    defaultUser,
}: let
    guestKernelModules = pkgs.makeModulesClosure {
        kernel = kernelPackage.modules or kernelPackage;
        firmware = pkgs.linux-firmware;
        # Allow built-in modules when archbox.kernelPackage is overridden with a custom kernel.
        allowMissing = true;
        rootModules = [
            "virtio_pci"
            "virtio_mmio"
            "virtio_blk"
            "virtio_net"
            "virtio_rng"
            "ext4"
            "overlay"
            "af_packet"
            "i8042"
            "atkbd"
        ];
    };

    initScript = pkgs.replaceVarsWith {
        name = "fcbox-init";
        src = ./scripts/init.sh;
        isExecutable = true;
        replacements = {
            inherit
                gatewayAddress
                primaryNameserver
                defaultUser
                ;
            inherit (pkgs) busybox;
        };
    };

    initrdImage = pkgs.makeInitrd {
        name = "fcbox-initrd";
        compressor = "gzip";
        contents = [
            {
                object = initScript;
                symlink = "/init";
            }
            {
                object = "${pkgs.busybox}/bin/busybox";
                symlink = "/bin/busybox";
            }
            {
                object = "${pkgs.kmod}/bin/kmod";
                symlink = "/bin/modprobe";
            }
            {
                object = "${guestKernelModules}/lib";
                symlink = "/lib";
            }
        ];
    };
in {
    inherit
        guestKernelModules
        initScript
        initrdImage
        ;
    initrdFile = "${initrdImage}/initrd";
}
