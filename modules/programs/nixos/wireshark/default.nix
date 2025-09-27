{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.nixos.wireshark;
in {
  config = lib.mkIf cfg.enable {
    programs.wireshark = {
      enable = true;
      usbmon.enable = true;
      dumpcap.enable = true;
    };
  };
}
