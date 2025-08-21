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
      code_editor = mkEnableOption "Code editors";
      containers = mkEnableOption "Container tools";
      tools = mkEnableOption "Core development tools";
    };

    nix-tools = {
      standard = mkEnableOption "Install nix tools (nixd, alejandra, statix)";
      full = mkEnableOption "Install nix tools (nixd, alejandra, statix, deadnix, vulnix, nix-du, nix-output-monitor, nix-tree, nix-diff, nix-update)";
    };

    multimedia = {
      office = mkEnableOption "Office suites";
      apps = mkEnableOption "Desktop communication apps";
    };

    gaming = {
      platform = mkEnableOption "Gaming platforms";
      utilities = mkEnableOption "Gaming utilities";
    };

    media = {
      editor = mkEnableOption "Media editors";
      viewer = mkEnableOption "Media viewers";
      screen_recorder = mkEnableOption "Screen recording tools";
      misc = mkEnableOption "Miscellaneous media tools";
    };

    wayland = {
      core = mkEnableOption "Core Wayland tools";
      wallpaper = mkEnableOption "Wallpaper managers";
      launcher = mkEnableOption "Application launchers";
      hyprland = mkEnableOption "Hyprland-specific utilities";
    };

    theming = {
      colors = mkEnableOption "Color generation tools";
      apps = mkEnableOption "Theming for specific apps";
      tools = mkEnableOption "Core theming engines";
      cursors = mkEnableOption "Install custom cursors";
      icons = mkEnableOption "Install icon themes";
      qt = mkEnableOption "Install Qt themes";
      gtk = mkEnableOption "Install GTK themes";

      defaultCursor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Default cursor theme package name";
      };

      defaultCursorSize = mkOption {
        type = types.int;
        default = 24;
        description = "Default cursor size";
      };
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
      type = with types; listOf str;
      default = [];
      description = "Package names to exclude";
    };
  };

  config = mkIf cfg.enable (
    let
      enabledPackages =
        (optionals cfg.android allPackages.android)
        ++ (optionals cfg.development.code_editor allPackages.development.code_editor)
        ++ (optionals cfg.development.containers allPackages.development.containers)
        ++ (optionals cfg.development.tools allPackages.development.tools)
        ++ (optionals cfg.fonts.nerd allPackages.fonts.nerd)
        ++ (optionals cfg.fonts.external allPackages.fonts.external)
        ++ (optionals cfg.gnome allPackages.gnome)
        ++ (optionals cfg.gaming.platform allPackages.gaming.platform)
        ++ (optionals cfg.gaming.utilities allPackages.gaming.utilities)
        ++ (optionals cfg.media.editor allPackages.media.editor)
        ++ (optionals cfg.media.viewer allPackages.media.viewer)
        ++ (optionals cfg.media.screen_recorder allPackages.media.screen_recorder)
        ++ (optionals cfg.media.misc allPackages.media.misc)
        ++ (optionals cfg.multimedia.office allPackages.multimedia.office)
        ++ (optionals cfg.multimedia.apps allPackages.multimedia.apps)
        ++ (optionals cfg.network allPackages.network)
        ++ (optionals cfg.nix-tools.standard allPackages.nix-tools.standard)
        ++ (optionals cfg.nix-tools.full allPackages.nix-tools.full)
        ++ (optionals cfg.security allPackages.security)
        ++ (optionals cfg.system allPackages.system)
        ++ (optionals cfg.theming.colors allPackages.theming.colors)
        ++ (optionals cfg.theming.apps allPackages.theming.apps)
        ++ (optionals cfg.theming.tools allPackages.theming.tools)
        ++ (optionals cfg.theming.cursors allPackages.theming.cursors)
        ++ (optionals cfg.theming.icons allPackages.theming.icons)
        ++ (optionals cfg.theming.qt allPackages.theming.qt)
        ++ (optionals cfg.theming.gtk allPackages.theming.gtk)
        ++ (optionals cfg.wayland.core allPackages.wayland.core)
        ++ (optionals cfg.wayland.wallpaper allPackages.wayland.wallpaper)
        ++ (optionals cfg.wayland.launcher allPackages.wayland.launcher)
        ++ (optionals cfg.wayland.hyprland allPackages.wayland.hyprland)
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
