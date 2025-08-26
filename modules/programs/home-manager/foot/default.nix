{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.home.foot;
  colors = config.shellix.matugen.colors.palette;
in {
  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          font = "CaskaydiaMono Nerd Font:size=10";
          font-size-adjustment = 0.7;
          box-drawings-uses-font-glyphs = true;
          dpi-aware = true;
          workers = 1;
        };

        cursor = {
          style = "beam";
          beam-thickness = 1;
        };

        colors = {
          foreground = colors.on_background.strip;
          background = colors.background.strip;
          regular0 = colors.scrim.strip;
          regular1 = colors.error.strip;
          regular2 = colors.secondary_fixed_dim.strip;
          regular3 = colors.tertiary.strip;
          regular4 = colors.primary_fixed.strip;
          regular5 = colors.inverse_surface.strip;
          regular6 = colors.surface_tint.strip;
          regular7 = colors.on_background.strip;
        };

        mouse = {
          hide-when-typing = true;
        };
      };
    };
  };
}
