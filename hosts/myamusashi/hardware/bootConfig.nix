{pkgs, ...}: {
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
        };

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
            "pcie_aspm=force"

            # Intel GPU optimizations
            "i915.enable_guc=3"
            "i915.enable_fbc=1"
            "i915.enable_psr=1"
            "i915.fastboot=1"

            # needs for ddcutil
            "acpi_backlight=native"

            # Performance tweaks
            "intel_pstate=active"
            "nmi_watchdog=0"
            "nowatchdog"

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
            "net.core.default_qdisc" = "cake";
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
            "kernel.threads-max" = 500000;
            "vm.max_map_count" = 1048576;

            "vm.vfs_cache_pressure" = 50;
            "vm.dirty_ratio" = 10;
            "vm.dirty_background_ratio" = 5;
            "vm.dirty_writeback_centisecs" = 1500;
            "vm.swappiness" = 10;
            "vm.page-cluster" = 0;

            "fs.inotify.max_user_watches" = 524288;
            "fs.file-max" = 2097152;

            "kernel.nmi_watchdog" = 0;
            "kernel.sched_migration_cost_ns" = 5000000;
            "kernel.sched_autogroup_enabled" = 1;
            "kernel.sched_latency_ns" = 4000000;
            "kernel.sched_min_granularity_ns" = 500000;
            "kernel.sched_wakeup_granularity_ns" = 1000000;
            "kernel.perf_event_paranoid" = 2; # Need this because intel-gpu-tools
        };
    };
}
