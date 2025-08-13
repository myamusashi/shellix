{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.shellix.programs.home;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.hyprland;

      plugins = [
        "${inputs.hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3}/lib/libhy3.so"
        "${inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors}/lib/libhypr-dynamic-cursors.so"
      ];

      settings = {
        # GANTI SEMUA pkgs.callPackage MENJADI import DI SINI
        exec-once = (import ./config/exec.nix {inherit pkgs;}).exec;
        input = import ./config/input.nix;
        general = import ./config/general.nix {inherit config;};
        decoration = import ./config/decoration.nix {inherit config;};
        misc = import ./config/misc.nix {inherit config;};
        cursor = import ./config/cursor.nix;
        render = import ./config/render.nix;
        xwayland = import ./config/xwayland.nix;
        animations = {
          enabled = lib.mkDefault true;
          bezier = (import ./config/animation.nix).bezier;
          animation = (import ./config/animation.nix).animation;
        };
        dwindle = import ./config/dwindle.nix;

        bind = (import ./config/keybinds.nix {inherit pkgs inputs lib;}).keybind;
        bindm = (import ./config/keybinds.nix {inherit pkgs inputs lib;}).m;
        binds = {drag_threshold = 10;};

        windowrulev2 = (import ./config/windowRules.nix).rule;
        layerrule = (import ./config/layerRules.nix).rule;
        permission = ["${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland, screencopy, allow"];
        plugin = {
          overview = (import ./config/plugin.nix {inherit config;}).hyprspace;
          hyprscrolling = {fullscreen_on_one_column = true;};
          hy3 = (import ./config/plugin.nix {inherit config;}).hy3;
          dynamic-cursors = (import ./config/plugin.nix {inherit config;}).dynamic-cursors;
        };
      };

      extraConfig = ''
        monitorv2 {
        	output = eDP-1
        	mode = preferred
        	position = 0x0
        	scale = 1.25
        }

        monitorv2 {
        	output = HDMI-A-2
        	mode = preferred
        	position = auto
        	scale = 1
        }
      '';
    };
  };
}
