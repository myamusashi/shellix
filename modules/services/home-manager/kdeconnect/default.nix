{
    config,
    lib,
    ...
}: let
    cfg = config.shellix.services.home-manager.kdeconnect;
in {
    config = lib.mkIf cfg.enable {
        services.kdeconnect = {
            enable = true;
            indicator = true;
        };
    };
}
