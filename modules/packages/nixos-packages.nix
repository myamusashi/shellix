{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shellix.packages.nixos;

  allPackages = import ./modules.nix {inherit pkgs config inputs lib;};
in {
  options.shellix.packages.nixos = {
    enable = mkEnableOption "Package management module";

    system = mkEnableOption "System utilities";
    network = mkEnableOption "Network tools";
    security = mkEnableOption "Security applications";
    gnome = mkEnableOption "GNOME specific packages";
    android = mkEnableOption "Android Debug Bridge";

    fonts = {
      nerd = mkEnableOption "Install nerd-fonts";
      external = mkEnableOption "Install external fonts";
    };

    development = {
      enable = mkEnableOption "Development tools category";
      code_editor = mkEnableOption "Code editors";
      containers = mkEnableOption "Container tools";
      tools = mkEnableOption "Core development tools";
    };

    multimedia = {
      enable = mkEnableOption "Multimedia category";
      office = mkEnableOption "Office suites";
      apps = mkEnableOption "Desktop communication apps";
    };

    gaming = {
      enable = mkEnableOption "Gaming category";
      platform = mkEnableOption "Gaming platforms";
      utilities = mkEnableOption "Gaming utilities";
    };

    media = {
      enable = mkEnableOption "Media category";
      editor = mkEnableOption "Media editors";
      viewer = mkEnableOption "Media viewers";
      screen_recorder = mkEnableOption "Screen recording tools";
      misc = mkEnableOption "Miscellaneous media tools";
    };

    wayland = {
      enable = mkEnableOption "Wayland category";
      core = mkEnableOption "Core Wayland tools";
      wallpaper = mkEnableOption "Wallpaper managers";
      launcher = mkEnableOption "Application launchers";
      hyprland = mkEnableOption "Hyprland-specific utilities";
    };

    theming = {
      enable = mkEnableOption "Theming category";
      colors = mkEnableOption "Color generation tools";
      apps = mkEnableOption "Theming for specific apps";
      tools = mkEnableOption "Core theming engines";
      cursors = mkEnableOption "Install custom cursors";
      icons = mkEnableOption "Install icon themes";
      qt = mkEnableOption "Install Qt themes";
      gtk = mkEnableOption "Install GTK themes";
    };

    languages = mkOption {
      type = types.listOf types.package;
      default = [];
      example = "pythonPackages.rich";
      description = "Just throw your favorite programe languages";
    };

    customPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra packages to install";
    };

    excludePackages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Package names to exclude";
      example = ["vim" "wofi"];
    };
  };

  config = mkIf cfg.enable (
    let
      enabledPackages =
        (optionals cfg.system allPackages.system)
        ++ (optionals cfg.network allPackages.network)
        ++ (optionals cfg.security allPackages.security)
        ++ (optionals cfg.gnome allPackages.gnome)
        ++ (optionals cfg.android allPackages.android)
        ++ (optionals cfg.development.code_editor allPackages.development.code_editor)
        ++ (optionals cfg.development.containers allPackages.development.containers)
        ++ (optionals cfg.development.tools allPackages.development.tools)
        ++ (optionals cfg.multimedia.office allPackages.multimedia.office)
        ++ (optionals cfg.multimedia.apps allPackages.multimedia.apps)
        ++ (optionals cfg.gaming.platform allPackages.gaming.platform)
        ++ (optionals cfg.gaming.utilities allPackages.gaming.utilities)
        ++ (optionals cfg.media.editor allPackages.media.editor)
        ++ (optionals cfg.media.viewer allPackages.media.viewer)
        ++ (optionals cfg.media.screen_recorder allPackages.media.screen_recorder)
        ++ (optionals cfg.media.misc allPackages.media.misc)
        ++ (optionals cfg.wayland.core allPackages.wayland.core)
        ++ (optionals cfg.wayland.wallpaper allPackages.wayland.wallpaper)
        ++ (optionals cfg.wayland.launcher allPackages.wayland.launcher)
        ++ (optionals cfg.wayland.hyprland allPackages.wayland.hyprland)
        ++ (optionals cfg.theming.colors allPackages.theming.colors)
        ++ (optionals cfg.theming.apps allPackages.theming.apps)
        ++ (optionals cfg.theming.tools allPackages.theming.tools)
        ++ (optionals cfg.theming.cursors allPackages.theming.cursors)
        ++ (optionals cfg.theming.icons allPackages.theming.icons)
        ++ (optionals cfg.theming.qt allPackages.theming.qt)
        ++ (optionals cfg.theming.gtk allPackages.theming.gtk)
        ++ cfg.languages
        ++ cfg.customPackages;

      fontPackages =
        (optionals cfg.fonts.nerd allPackages.fonts.nerd)
        ++ (optionals cfg.fonts.external allPackages.fonts.external);

      filteredPackages =
        filter (
          pkg: let
            pkgName = pkg.pname or pkg.name or "unknown";
          in
            !(elem pkgName cfg.excludePackages)
        )
        enabledPackages;
    in
      mkMerge [
        {
          environment.systemPackages = filteredPackages;
        }

        (mkIf (fontPackages != []) {
          fonts.packages = fontPackages;
        })
      ]
  );
}
