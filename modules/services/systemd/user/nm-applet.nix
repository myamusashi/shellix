{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.shellix.services.systemd.user.nm-applet.enable {
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
