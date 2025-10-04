{
  lib,
  config,
  ...
}: let
  cfg = config.shellix.programs.home.lazygit;
in {
  config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
    };
  };
}
