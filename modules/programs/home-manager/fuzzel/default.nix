{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.shellix.programs.home;
  colors = config.shellix.matugen.colors.palette;
in {
  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          terminal = "${pkgs.foot}/bin/foot";
          font = "JetBrains Mono NF:size=17";
          prompt = "/ ";
          layer = "overlay";
          lines = 15;
          width = 60;
          horizontal-pad = 40;
          vertical-pad = 15;
        };
        colors = {
          background = colors.background.hex16bit;
          text = colors.on_surface.hex16bit;
          border = colors.primary.hex16bit;
          match = colors.tertiary.hex16bit;
          selection = colors.primary.hex16bit;
          selection-match = colors.on_primary.hex16bit;
          selection-text = colors.on_surface.hex16bit;
          input = colors.primary.hex16bit;
          counter = colors.secondary.hex16bit;
        };
      };
    };
  };
}
