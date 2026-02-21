{lib, ...}: {
    imports = [
        ./adzan.nix
        ./caelestia.nix
        ./nm-applet.nix
        ./getAdzanData.nix
        ./weather-widget.nix
        ./shell.nix
    ];

    options.shellix.services.systemd.user = {
        adzan.enable = lib.mkEnableOption "Enable adzan services";
        caelestia.enable = lib.mkEnableOption "Enable caelestia shell services";
        nm-applet.enable = lib.mkEnableOption "Enable network-managers tray";
        shell.enable = lib.mkEnableOption "Enable shell widget services";
        weather-widget.enable = lib.mkEnableOption "Enable weather-widget using quickshell";
    };
}
