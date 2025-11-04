{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.home.shell;
in {
  imports = [
    inputs.shell.homeManagerModules.default
  ];

  programs.quickshell-shell = lib.mkIf cfg.enable {
    enable = true;
		installFonts = false;
  };
}
