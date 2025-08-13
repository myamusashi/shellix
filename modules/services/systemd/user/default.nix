{lib, ...}: {
  imports = [
    ./adzan.nix
    ./caelestia.nix
    ./nm-applet.nix
    ./getAdzanData.nix
    ./weather-widget.nix
  ];

  options.shellix.services.systemd.user = {
    adzan = {
      enable = lib.mkEnableOption "Enable adzan services";
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
