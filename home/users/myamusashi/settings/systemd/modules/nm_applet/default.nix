{pkgs, ...}: {
  systemd.user.services.nm-applet = {
    description = "NetworkManager Applet";
    wantedBy = ["graphical-session.target"];
    after = ["hyprland-session.target" "graphical-session.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
      Restart = "always";
      RestartSec = 1;

      # Import environment dari user session
      PassEnvironment = ["DISPLAY" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"];
    };

    environment = {
      DISPLAY = ":0";
      WAYLAND_DISPLAY = "wayland-1";
      XDG_CURRENT_DESKTOP = "Hyprland";
    };
  };
}
