{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.services.mpd;
in {
  options.shellix.services.mpd = {
    enable = lib.mkEnableOption "Enable MPD players services";
  };

  config = lib.mkIf cfg.enable {
    services.mpd = {
      enable = true;
      user = "myamusashi";
      musicDirectory = "/home/myamusashi/Music/playlists";
      network.listenAddress = "any";
    };
  };
}
