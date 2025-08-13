{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.nixos;
in {
  config = lib.mkIf cfg.enable {
    programs.wireshark = {
      enable = true;
      usbmon.enable = true;
      dumpcap.enable = true;
    };
  };
}
