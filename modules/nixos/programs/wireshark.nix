{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.wireshark;
in {
    config = lib.mkIf cfg.enable {
        programs.wireshark = {
            enable = true;
            package = pkgs.wireshark;
            usbmon.enable = true;
            dumpcap.enable = true;
        };
    };
}
