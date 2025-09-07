{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.themes;
  color = config.shellix.matugen.colors.palette;
in {
  options.shellix.themes = {
    btop.enable = lib.mkEnableOption "Enable btop themes using matugen colors";
    gtk3.enable = lib.mkEnableOption "Enable GTK3 extra CSS using matugen";
    gtk4.enable = lib.mkEnableOption "Enable GTK3 extra CSS using matugen";
    yazi.enable = lib.mkEnableOption "Enable yazi flavors using matugen";
    kvantum.enable = lib.mkEnableOption "Enable kvantum themes using matugen colors and WhiteSur templates";
    hyprqt6engine.enable = lib.mkEnableOption "Enable hyprqt6engine for hyprland ecosystem";
    zellij.enable = lib.mkEnableOption "Enable zellij themes using matugen";
  };

  config = {
    gtk.gtk3.extraCss = lib.mkIf cfg.gtk3.enable ''
      @define-color accent_color ${color.primary_fixed_dim.hex};
      @define-color accent_fg_color ${color.on_primary_fixed.hex};
      @define-color accent_bg_color ${color.primary_fixed_dim.hex};
      @define-color window_bg_color ${color.surface_dim.hex};
      @define-color window_fg_color ${color.on_surface.hex};
      @define-color headerbar_bg_color ${color.surface_dim.hex};
      @define-color headerbar_fg_color ${color.on_surface.hex};
      @define-color popover_bg_color ${color.surface_dim.hex};
      @define-color popover_fg_color ${color.on_surface.hex};
      @define-color view_bg_color ${color.surface.hex};
      @define-color view_fg_color ${color.on_surface.hex};
      @define-color card_bg_color ${color.surface.hex};
      @define-color card_fg_color ${color.on_surface.hex};
      @define-color sidebar_bg_color @window_bg_color;
      @define-color sidebar_fg_color @window_fg_color;
      @define-color sidebar_border_color @window_bg_color;
      @define-color sidebar_backdrop_color @window_bg_color;
    '';

    gtk.gtk4.extraCss = lib.mkIf cfg.gtk4.enable ''
      @define-color accent_color ${color.primary_fixed_dim.hex};
      @define-color accent_fg_color ${color.on_primary_fixed.hex};
      @define-color accent_bg_color ${color.primary_fixed_dim.hex};
      @define-color window_bg_color ${color.surface_dim.hex};
      @define-color window_fg_color ${color.on_surface.hex};
      @define-color headerbar_bg_color ${color.surface_dim.hex};
      @define-color headerbar_fg_color ${color.on_surface.hex};
      @define-color popover_bg_color ${color.surface_dim.hex};
      @define-color popover_fg_color ${color.on_surface.hex};
      @define-color view_bg_color ${color.surface.hex};
      @define-color view_fg_color ${color.on_surface.hex};
      @define-color card_bg_color ${color.surface.hex};
      @define-color card_fg_color ${color.on_surface.hex};
      @define-color sidebar_bg_color @window_bg_color;
      @define-color sidebar_fg_color @window_fg_color;
      @define-color sidebar_border_color @window_bg_color;
      @define-color sidebar_backdrop_color @window_bg_color;
    '';

    home.file = {
      ".config/btop/themes/shellix.theme" = lib.mkIf cfg.btop.enable {
        inherit (import ./modules/btop.nix {inherit config;}) enable text;
      };

      ".config/hypr/hyprqt6engine.conf" = lib.mkIf cfg.hyprqt6engine.enable {
        inherit (import ./modules/hyprqt6engine.nix {inherit config;}) enable text;
      };

      ".config/zellij/themes/shellix.kdl" = lib.mkIf cfg.zellij.enable {
        inherit (import ./modules/zellij.nix {inherit config;}) enable text;
      };

      ".config/yazi/flavors/shellix.yazi/flavor.toml" = lib.mkIf cfg.yazi.enable {
        inherit (import ./modules/yazi.nix {inherit config;}) enable text;
      };
      ".config/Kvantum/Shellix/Shellix.kvconfig" = lib.mkIf cfg.kvantum.enable {
        inherit (import ./modules/kvantum/default.nix {inherit config;}) enable text;
      };
      ".config/Kvantum/Shellix/Shellix.svg" = lib.mkIf cfg.kvantum.enable {
        enable = true;
        text = builtins.readFile ./modules/kvantum/Shellix.svg;
      };
    };
  };
}
