{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.shellix.programs.nixos;
in {
  config = lib.mkIf cfg.enable {
    programs.xonsh = {
      enable = true;
      package = pkgs.xonsh;
      config = ''
        execx($(starship init xonsh))
      '';
    };
  };
}
