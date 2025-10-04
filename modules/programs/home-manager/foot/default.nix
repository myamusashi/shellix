{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.home.foot;
in {
  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
    };
  };
}
