{
    config,
    lib,
    ...
}: let
    cfg = config.shellix.services.kdeconnect;
in {
    config = lib.mkIf cfg.enable {
        programs.kdeconnect = {
            enable = true;
        };
    };
}
