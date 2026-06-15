{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.shell;
in {
  imports = [
    inputs.shell.nixosModules.default
  ];

  options.shellix.programs.shell = {
    enable = lib.mkEnableOption "Enable shell widgets";
  };

  config = lib.mkIf cfg.enable {
    programs.quickshell-shell = {
      enable = true;
      installFonts = false;
    };
  };
}
