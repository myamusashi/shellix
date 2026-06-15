{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.shellix.programs.quickshell;
  quickshell-pkg = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  options.shellix.programs.quickshell = {
    enable = lib.mkEnableOption "Enable Quickshell qt widget and shell applications";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [quickshell-pkg];
  };
}
