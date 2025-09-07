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
    adzan = {
      enable = lib.mkEnableOption "Enable adzan services";
    };
    shell = {
      enable = lib.mkEnableOption "Enable shell widget services";
    };
    caelestia = {
      enable = lib.mkEnableOption "Enable caelestia shell services";
    };
    nm-applet = {
      enable = lib.mkEnableOption "Enable network-managers tray";
    };
    weather-widget = {
      enable = lib.mkEnableOption "Enable weather-widget using quickshell";
    };
  };
}
