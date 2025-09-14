{
  lib,
  config,
  ...
}: let
  cfg = config.shellix.programs.nixos;
in {
  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;
  };
}
