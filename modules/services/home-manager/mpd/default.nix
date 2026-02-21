{
    config,
    lib,
    ...
}: let
    cfg = config.shellix.services.home-manager.mpd;
in {
    config = lib.mkIf cfg.enable {
        services.mpd = {
            enable = true;
            musicDirectory = "${config.home.homeDirectory}/Music/playlists";
            network.listenAddress = "any";
            network.startWhenNeeded = true;
        };
    };
}
