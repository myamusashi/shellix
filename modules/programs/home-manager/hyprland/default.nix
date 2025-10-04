{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.shellix.programs.home.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.hyprland;

      plugins = [
        "${inputs.hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3}/lib/libhy3.so"
        "${inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors}/lib/libhypr-dynamic-cursors.so"
      ];

      importantPrefixes = [
        "$"
        "source"
        "output"
        "bezier"
        "name"
      ];

      settings = import ./config {inherit pkgs config inputs lib;};
    };
  };
}
