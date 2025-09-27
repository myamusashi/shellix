{
  pkgs,
  config,
  lib,
  ...
}: {
  inherit (import ./exec.nix {inherit pkgs;}) exec-once;
  inherit (import ./input.nix) input;
  inherit (import ./general.nix {inherit config;}) general;
  inherit (import ./decoration.nix {inherit config;}) decoration;
  inherit (import ./misc.nix {inherit config;}) misc;
  inherit (import ./cursor.nix) cursor;
  inherit (import ./render.nix) render;
  inherit (import ./xwayland.nix) xwayland;
  inherit (import ./animation.nix {inherit lib;}) animations;
  inherit (import ./dwindle.nix) dwindle;
  inherit (import ./keybinds.nix {inherit config;}) bind bindm binds;
  inherit (import ./rule.nix) windowrulev2 layerrule;
  inherit (import ./permission.nix {inherit pkgs;}) permission;
  inherit (import ./plugin.nix {inherit config;}) plugin;
  inherit (import ./monitors.nix) monitorv2;
}
