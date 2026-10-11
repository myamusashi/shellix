{
    config,
    lib,
    ...
}: {
    options.shellix.services.earlyoom = {
        freeMemKillThreshold = lib.mkOption {
            type = lib.types.ints.positive;
            default = 6;
            description = "Percent of free RAM below which earlyoom kills the biggest process. The absolute headroom scales with RAM, so small hosts may want a different value than the 16 GB default.";
        };
        freeSwapKillThreshold = lib.mkOption {
            type = lib.types.ints.positive;
            default = 6;
            description = "Percent of free swap below which earlyoom kills the biggest process.";
        };
    };

    config = lib.mkIf config.shellix.services.earlyoom.enable {
        services.earlyoom = {
            enable = true;
            enableNotifications = true;
            freeMemKillThreshold = config.shellix.services.earlyoom.freeMemKillThreshold;
            freeSwapKillThreshold = config.shellix.services.earlyoom.freeSwapKillThreshold;
        };
    };
}
