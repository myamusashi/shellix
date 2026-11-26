{inputs, ...}: {
    flake.modules.nixos.myamusashiHardware = {
        config,
        lib,
        modulesPath,
        pkgs,
        ...
    }: {
        key = "shellix.nixos.myamusashiHardware";

        imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x270
            inputs.bootvine.nixosModules.default
        ];

        services = {
            bootvine.enable = true;
            fwupd.enable = true;
            thermald.enable = true;
            power-profiles-daemon.enable = false;
            fprintd.enable = false;
            irqbalance.enable = true;

            fstrim = {
                enable = true;
                interval = "weekly";
            };

            udev.extraRules = ''
                ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/scheduler}="mq-deadline"

                KERNEL=="uhid", SUBSYSTEM=="misc", OPTIONS+="static_node=uhid", TAG+="uaccess", GROUP="input", MODE="0660"
            '';

            tlp = {
                enable = true;
                settings = {
                    CPU_SCALING_DRIVER_ON_AC = "intel_pstate";
                    CPU_SCALING_DRIVER_ON_BAT = "intel_pstate";
                    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
                    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
                    CPU_BOOST_ON_AC = 1;
                    CPU_BOOST_ON_BAT = 0;
                    PLATFORM_PROFILE_ON_AC = "performance";
                    PLATFORM_PROFILE_ON_BAT = "powersave";
                    PCIE_ASPM_ON_AC = "performance";
                    PCIE_ASPM_ON_BAT = "default";
                    RUNTIME_PM_ON_AC = "on";
                    RUNTIME_PM_ON_BAT = "auto";
                    DISK_IDLE_SECS_ON_AC = 0;
                    DISK_IDLE_SECS_ON_BAT = 2;
                    SOUND_POWER_SAVE_ON_AC = 0;
                    SOUND_POWER_SAVE_ON_BAT = 1;
                    USB_AUTOSUSPEND = 0;
                    START_CHARGE_THRESH_BAT0 = 80;
                    STOP_CHARGE_THRESH_BAT0 = 80;
                    START_CHARGE_THRESH_BAT1 = 75;
                    STOP_CHARGE_THRESH_BAT1 = 75;
                };
            };

            journald.settings.Journal = {
                SystemMaxUse = "100M";
                MaxRetentionSec = "7day";
            };
        };

        boot = {
            kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;
            consoleLogLevel = 0;
            initrd = {
                availableKernelModules = [
                    "xhci_pci"
                    "ahci"
                    "usbhid"
                    "usb_storage"
                    "sd_mod"
                    "rtsx_pci_sdmmc"
                ];
                kernelModules = [];
            };
            extraModulePackages = [];

            loader = {
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
            };

            plymouth.enable = true;
            supportedFilesystems = ["ntfs3"];

            kernelModules = [
                "kvm-intel"
                "i915"
                "uas"
                "usbhid"
                "hid"
                "usb_storage"
                "zram"
                "i2c-dev"
                "msr"
                "tcp_bbr"
                "ntsync"
            ];

            kernelParams = [
                "quiet"
                "splash"
                "loglevel=3"
                "boot.shell_on_fail"
                "rd.systemd.show_status=false"
                "rd.udev.log_level=3"
                "udev.log_priority=3"
                "console=tty1"
                "i915.enable_fbc=1"
                # Required by ddcutil for ThinkPad backlight control.
                "acpi_backlight=native"
            ];

            kernel.sysctl = {
                "net.core.default_qdisc" = "cake";
                "net.core.rmem_max" = 16777216;
                "net.core.wmem_max" = 16777216;
                "net.core.somaxconn" = 1024;
                "net.core.netdev_max_backlog" = 5000;
                "net.ipv4.tcp_rmem" = "4096 87380 16777216";
                "net.ipv4.tcp_wmem" = "4096 87380 16777216";
                "net.ipv4.tcp_congestion_control" = "bbr";
                "net.ipv4.ip_forward" = 1;
                "net.ipv4.tcp_fastopen" = 3;
                "net.ipv4.tcp_slow_start_after_idle" = 0;
                "net.ipv4.tcp_mtu_probing" = 1;
                "net.ipv4.tcp_window_scaling" = 1;
                "net.ipv4.tcp_keepalive_time" = 60;
                "net.ipv4.tcp_keepalive_intvl" = 10;
                "net.ipv4.tcp_keepalive_probes" = 6;
                "vm.vfs_cache_pressure" = 50;
                "vm.dirty_ratio" = 10;
                "vm.dirty_background_ratio" = 5;
                "vm.dirty_writeback_centisecs" = 1500;
                "vm.swappiness" = 10;
                "vm.page-cluster" = 0;
                "fs.inotify.max_user_watches" = 524288;
                "fs.file-max" = 2097152;
                "kernel.sched_autogroup_enabled" = 1;
                # Required by intel-gpu-tools perfmon sampling.
                "kernel.perf_event_paranoid" = 2;
            };
        };

        fileSystems = {
            "/" = {
                device = "/dev/disk/by-uuid/47218c3c-d84b-4fbb-8b6e-3c3aedc1bed7";
                fsType = "ext4";
            };
            "/boot" = {
                device = "/dev/disk/by-uuid/367D-269A";
                fsType = "vfat";
                options = [
                    "fmask=0077"
                    "dmask=0077"
                ];
            };
        };

        swapDevices = [];

        zramSwap = {
            enable = true;
            priority = 1;
            algorithm = "lz4";
            memoryPercent = 50;
            memoryMax = 4294967296;
        };

        hardware = {
            cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
            sensor.iio.enable = true;
            i2c.enable = true;
            acpilight.enable = true;
            bluetooth = {
                enable = true;
                powerOnBoot = true;
            };
            graphics = {
                enable = true;
                enable32Bit = true;
                extraPackages = [
                    pkgs.vulkan-loader
                    pkgs.libGLX
                    pkgs.libGL
                    pkgs.libva
                    pkgs.intel-media-driver
                ];
                extraPackages32 = [
                    pkgs.pkgsi686Linux.intel-media-driver
                ];
            };
        };

        security = {
            apparmor.enable = true;
            wrappers.intel_gpu_top = {
                source = "${pkgs.intel-gpu-tools}/bin/intel_gpu_top";
                capabilities = "cap_perfmon+ep";
                owner = "myamusashi";
                group = "root";
            };
        };

        virtualisation = {
            libvirtd.enable = true;
            docker.enable = false;
            podman.enable = false;
            vmware = {
                host.enable = false;
                guest = {
                    enable = true;
                    headless = false;
                };
            };
        };

        environment = {
            etc = {
                "icc/thinkpad-x270.icm".source = ../../../assets/icc/thinkpad_270_icc.icm;
                "icc/lg-mk400.icm".source = ../../../assets/icc/lg_mk400_icc.icm;
            };
            systemPackages = [
                pkgs.libva-utils
                pkgs.virtualgl
                pkgs.vulkan-tools
                pkgs.pciutils
                pkgs.udisks
                pkgs.udiskie
            ];
        };

        networking.useDHCP = lib.mkDefault true;
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
