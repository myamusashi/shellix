{pkgs, ...}: {
    imports = [
        "${fetchGit {
            url = "https://github.com/NixOS/nixos-hardware.git";
            rev = "2379bc40992ec29feb1933bb4acd224fa055f3f8";
        }}/lenovo/thinkpad/x270"
        ./hardware-configuration.nix
    ];

    environment.systemPackages = with pkgs; [
        intel-gpu-tools
        iio-sensor-proxy
    ];

    powerManagement.cpuFreqGovernor = "performance";

    hardware = {
        sensor.iio.enable = true;
        bluetooth = {
            enable = true;
            powerOnBoot = true;
        };

        graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
                vulkan-loader
                intel-media-driver
                intel-vaapi-driver
                libva-vdpau-driver
                libva
                libvdpau-va-gl
            ];
            extraPackages32 = with pkgs.pkgsi686Linux; [
                intel-media-driver
            ];
        };
    };

    virtualisation = {
        docker.enable = false;
        libvirtd.enable = true;
        podman = {
            enable = true;
            dockerCompat = true;
            dockerSocket.enable = true;
            defaultNetwork.settings.dns_enabled = true;
        };
        vmware = {
            host.enable = true;
            guest = {
                enable = true;
                headless = false;
            };
        };
    };

    fileSystems."/".options = ["discard"];

    boot = {
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
        initrd.verbose = false;
        consoleLogLevel = 0;
        initrd.availableKernelModules = [
            "xhci_pci"
            "ahci"
            "usbhid"
            "sd_mod"
            "rtsx_pci_sdmmc"
        ];

        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };

        plymouth = {
            enable = true;
            theme = "cross_hud";
            themePackages = with pkgs; [
                (adi1090x-plymouth-themes.override {
                    selected_themes = ["cross_hud"];
                })
            ];
        };

        supportedFilesystems = ["ntfs"];

        kernelModules = [
            "kvm-intel"
            "i915"
            "uas"
            "usbhid"
            "hid"
            "usb_storage"
            "zram"
        ];

        kernelParams = [
            "quiet"
            "splash"
            "loglevel=3"
            "acpi_backlight=video"
            "boot.shell_on_fail"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
            "console=tty1"

            # Intel GPU optimizations
            "i915.enable_fbc=1"
            "i915.enable_psr=2"
            "i915.fastboot=1"

            # Performance tweaks
            "intel_pstate=active"
            "nmi_watchdog=0"

            # Disable mitigations (kinda risky tbh)
            "noibrs"
            "noibpb"
            "nopti"
            "nospectre_v2"
            "nospectre_v1"
            "l1tf=off"
            "nospec_store_bypass_disable"
            "no_stf_barrier"
            "mds=off"
            "mitigations=off"
        ];

        kernel.sysctl = {
            "net.core.default_qdisc" = "fq";
            "net.core.rmem_max" = 16777216;
            "net.core.wmem_max" = 16777216;
            "net.core.somaxconn" = 1024;
            "net.core.netdev_max_backlog" = 5000;

            "net.ipv4.tcp_rmem" = "4096 87380 16777216";
            "net.ipv4.tcp_wmem" = "4096 87380 16777216";
            "net.ipv4.tcp_congestion_control" = "bbr";
            "net.ipv4.ip_forward" = 1; ## Cloudflare warp
            "net.ipv4.tcp_fastopen" = 3;
            "net.ipv4.tcp_slow_start_after_idle" = 0;
            "net.ipv4.tcp_mtu_probing" = 1;
            "net.ipv4.tcp_window_scaling" = 1;
            "net.ipv4.tcp_keepalive_time" = 60;
            "net.ipv4.tcp_keepalive_intvl" = 10;
            "net.ipv4.tcp_keepalive_probes" = 6;

            # I hate android studio and flutter
            "vm.overcommit_memory" = 1;
            "vm.max_map_count" = 262144;

            "vm.vfs_cache_pressure" = 50;
            "vm.dirty_ratio" = 6;
            "vm.dirty_background_ratio" = 3;
            "vm.dirty_writeback_centisecs" = 1500;
            "vm.swappiness" = 10;
            "vm.page-cluster" = 0;

            "fs.inotify.max_user_watches" = 524288;
            "fs.file-max" = 2097152;

            "kernel.sched_migration_cost_ns" = 5000000;
            "kernel.sched_autogroup_enabled" = 0;
            "kernel.perf_event_paranoid" = 2; # Need this because intel-gpu-tools
        };
    };

    services = {
        fstrim = {
            enable = true;
            interval = "weekly";
        };

        irqbalance.enable = true;
    };

    services.journald.extraConfig = ''
        SystemMaxUse=100M
        MaxRetentionSec=7day
    '';

    security = {
        wrappers.gsr-kms-server = {
            source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
            capabilities = "cap_sys_admin+ep";
            owner = "root";
            group = "root";
        };

        wrappers.intel_gpu_top = {
            source = "${pkgs.intel-gpu-tools}/bin/intel_gpu_top";
            capabilities = "cap_perfmon+ep";
            owner = "root";
            group = "root";
        };
    };

    zramSwap = {
        enable = true;
        priority = 1;
        algorithm = "zstd";
        memoryPercent = 50;
        memoryMax = null;
    };
    # swapDevices = lib.mkForce [];
}
