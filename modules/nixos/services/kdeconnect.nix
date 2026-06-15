{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.services.kdeconnect;
in {
  options.shellix.services.kdeconnect = {
    enable = lib.mkEnableOption "Enable kdeconnect";
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect = {
      enable = true;
    };
  };
}
