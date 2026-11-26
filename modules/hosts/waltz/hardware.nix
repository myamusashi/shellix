{
    flake.modules.nixos.waltzHardware = {
        config,
        lib,
        modulesPath,
        pkgs,
        ...
    }: {
        key = "shellix.nixos.waltzHardware";

        imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
        ];

        boot = {
            loader = {
                efi.canTouchEfiVariables = true;
                systemd-boot.enable = true;
            };
            kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-server;
            supportedFilesystems = ["ntfs"];
            initrd = {
                availableKernelModules = [
                    "ahci"
                    "xhci_pci"
                    "usb_storage"
                    "sd_mod"
                    "sr_mod"
                    "rtsx_usb_sdmmc"
                ];
                kernelModules = [];
            };
            kernelModules = ["kvm-intel"];
            extraModulePackages = [];

            # 2 GB RAM hosting server stack + Firecracker MicroVM: favor zram over disk swap I/O on the 6 W N3350.
            kernel.sysctl."vm.swappiness" = 180;
        };

        zramSwap = {
            enable = true;
            priority = 100;
            algorithm = "lz4";
            memoryPercent = 50;
            memoryMax = 1073741824;
        };

        hardware = {
            cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
            graphics = {
                enable = true;
                enable32Bit = true;
                extraPackages = with pkgs; [
                    intel-media-driver
                    intel-vaapi-driver
                    libva-vdpau-driver
                    libva
                    libvdpau-va-gl
                ];
                extraPackages32 = [
                    pkgs.pkgsi686Linux.intel-media-driver
                    pkgs.pkgsi686Linux.intel-vaapi-driver
                ];
            };
        };

        virtualisation = {
            libvirtd.enable = false;
            docker.enable = false;
            podman.enable = false;
        };

        fileSystems = {
            "/" = {
                device = "/dev/disk/by-uuid/9b528eb1-8c09-4594-8a57-eaeff52169f7";
                fsType = "ext4";
                options = ["noatime"];
            };

            "/boot" = {
                device = "/dev/disk/by-uuid/C004-427D";
                fsType = "vfat";
                options = [
                    "fmask=0022"
                    "dmask=0022"
                ];
            };

            "/home/waltz/external" = {
                device = "/dev/disk/by-label/BACKUP";
                fsType = "ntfs";
                options = [
                    "noatime"
                    "nofail"
                    "rw"
                    "uid=1000"
                    "gid=100"
                ];
            };

            "/opt/backup" = {
                device = "/home/waltz/external";
                depends = ["/home/waltz/external"];
                fsType = "none";
                options = [
                    "bind"
                    "nofail"
                ];
            };
        };

        swapDevices = [
            {device = "/dev/disk/by-uuid/e71f5226-0e38-42b8-880e-0114ba1defdd";}
        ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
