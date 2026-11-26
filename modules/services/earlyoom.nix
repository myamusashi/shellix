{
    flake.modules.nixos.earlyoom = {
        config,
        lib,
        ...
    }: let
        earlyoomConfig = config.shellix.earlyoom;
    in {
        key = "shellix.nixos.earlyoom";

        options.shellix.earlyoom = {
            freeMemoryKillThreshold = lib.mkOption {
                type = lib.types.ints.positive;
                default = 6;
                description = "Percent of free RAM below which earlyoom kills the biggest process.";
            };
            freeSwapKillThreshold = lib.mkOption {
                type = lib.types.ints.positive;
                default = 6;
                description = "Percent of free swap below which earlyoom kills the biggest process.";
            };
        };

        config.services.earlyoom = {
            enable = true;
            enableNotifications = true;
            freeMemKillThreshold = earlyoomConfig.freeMemoryKillThreshold;
            inherit (earlyoomConfig) freeSwapKillThreshold;
        };
    };
}
