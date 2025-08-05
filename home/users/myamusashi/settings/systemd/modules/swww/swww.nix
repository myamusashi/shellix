{pkgs, ...}: {
  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww wayland wallpaper daemon";
      After = ["hyprland-session.target"];
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      ExecStop = "${pkgs.swww}/bin/swww kill";
      Restart = "always";
      RestartSec = "3";
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };
}
