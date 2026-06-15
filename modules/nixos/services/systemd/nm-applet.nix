{
  lib,
  config,
  pkgs,
  ...
}: {
  options.shellix.services.systemd.nm-applet = {
    enable = lib.mkEnableOption "Enable network manager applet tray widgets";
  };

  config = lib.mkIf config.shellix.services.systemd.nm-applet.enable {
    systemd.user.services.nm-applet = {
      Unit = {
        Description = "network manager tray";
        After = ["hyprland-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
