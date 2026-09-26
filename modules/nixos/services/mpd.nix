{
    config,
    lib,
    ...
}: let
    cfg = config.shellix.services.mpd;
in {
    config = lib.mkIf cfg.enable {
        services.mpd = {
            enable = true;
            user = "myamusashi";
            musicDirectory = "/home/myamusashi/Music/playlists";
            network.listenAddress = "any";
        };
    };
}
