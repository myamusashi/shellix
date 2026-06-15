{
    config,
    lib,
    ...
}: let
    cfg = config.shellix.services.minidlna;
in {
    config = lib.mkIf cfg.enable {
        services.minidlna = {
            enable = true;

            settings = {
                media_dir = [
                    "/data/media"
                    "V,$HOME/Videos"
                    "P,$HOME/Pictures"
                ];
            };
        };

        users.users.minidlna = {
            isSystemUser = true;
            group = "minidlna";
        };

        users.groups.minidlna = {};
    };
}
