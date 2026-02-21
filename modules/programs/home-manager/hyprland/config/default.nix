{
    pkgs,
    config,
    lib,
    ...
}: let
    vars = import ./variable.nix {inherit config;};
in
    vars
    // {
        source = [
            "${config.home.homeDirectory}/.config/hypr/colors.conf"
            "${config.home.homeDirectory}/.config/mushell/hyprland.conf"
        ];
        inherit (import ./exec.nix) exec-once;
        inherit (import ./input.nix) input;
        inherit (import ./general.nix {inherit config;}) general;
        inherit (import ./decoration.nix) decoration;
        inherit (import ./misc.nix) misc;
        inherit (import ./cursor.nix) cursor;
        inherit (import ./render.nix) render;
        inherit (import ./xwayland.nix) xwayland;
        inherit (import ./animation.nix {inherit lib;}) animations;
        inherit (import ./dwindle.nix) dwindle;
        inherit (import ./keybinds.nix {inherit config;}) bind bindm binds;
        inherit (import ./rule.nix) windowrule layerrule;
        inherit (import ./permission.nix {inherit pkgs;}) permission;
        inherit (import ./plugin.nix {inherit lib config;}) plugin;
        inherit (import ./monitors.nix) monitorv2;
        inherit (import ./workspaces.nix) workspace;
    }
