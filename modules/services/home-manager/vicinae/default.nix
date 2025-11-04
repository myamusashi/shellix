{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.shellix.services.home-manager.vicinae;
in {
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];
  config = lib.mkIf cfg.enable {
    services.vicinae = {
      enable = true;
      autoStart = true;
      useLayerShell = false;

      settings = {
        popToRootOnClose = false;
        rootSearch.searchFiles = false;
        theme.name = "shellix";
      };
    };
  };
}
