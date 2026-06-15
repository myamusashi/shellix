{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.foot;
in {
  options.shellix.programs.foot = {
    enable = lib.mkEnableOption "Enable Foot terminal applications";
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
    };
  };
}
