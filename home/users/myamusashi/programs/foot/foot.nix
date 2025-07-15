let
  matugen = import ./matugen.nix;
in {
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
        foreground = matugen.on_background;
        background = matugen.background;
        regular0 = matugen.scrim; #black
        regular1 = matugen.error; #red
        regular2 = matugen.secondary; #green
        regular3 = matugen.tertiary; #yellow
        regular4 = matugen.inverse_on_surface; #blue
        regular5 = matugen.primary_container; #magenta
        regular6 = matugen.surface_tint; #cyan
        regular7 = matugen.on_background; #white
      };

      mouse = {
        hide-when-typing = true;
      };
    };
  };
}
