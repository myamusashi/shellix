{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.shellix.programs.home.vscode;
in {
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default = {
        enableExtensionUpdateCheck = true;
        enableUpdateCheck = true;
      };
    };
  };
}
