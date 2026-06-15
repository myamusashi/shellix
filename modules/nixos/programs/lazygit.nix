{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.shellix.programs.lazygit;
in {
  options.shellix.programs.lazygit = {
    enable = lib.mkEnableOption "Enable Lazygit TUI applications";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.lazygit];
  };
}
