{
    services = {
        power-profiles-daemon.enable = false;
        davfs2.enable = true;
        fprintd.enable = false;
        fstrim = {
            enable = true;
            interval = "weekly";
        };

        udev.extraRules = ''
            ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/scheduler}="mq-deadline"
        '';

        tlp = {
            enable = true;
            settings = {
                CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
                CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";

                CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
                CPU_ENERGY_PERF_POLICY_ON_BAT = "performance";

                CPU_MIN_PERF_ON_AC = 0;
                CPU_MAX_PERF_ON_AC = 100;
                CPU_MIN_PERF_ON_BAT = 0;
                CPU_MAX_PERF_ON_BAT = 30;

                CPU_BOOST_ON_AC = 1;
                CPU_BOOST_ON_BAT = 0;
                CPU_HWP_DYN_BOOST_ON_AC = 1;
                CPU_HWP_DYN_BOOST_ON_BAT = 0;

                PLATFORM_PROFILE_ON_AC = "performance";
                PLATFORM_PROFILE_ON_BAT = "performance";

                PCIE_ASPM_ON_AC = "performance";
                PCIE_ASPM_ON_BAT = "performance";

                RUNTIME_PM_ON_AC = "on";
                RUNTIME_PM_ON_BAT = "auto";

                DISK_IDLE_SECS_ON_AC = 0;
                DISK_IDLE_SECS_ON_BAT = 2;

                SOUND_POWER_SAVE_ON_AC = 0;
                SOUND_POWER_SAVE_ON_BAT = 1;
                USB_AUTOSUSPEND = 0;
            };
        };

        irqbalance.enable = true;

        journald.settings.Journal = {
            SystemMaxUse = "100M";
            MaxRetentionSec = "7day";
        };
    };
}
