{pkgs, ...}: {
  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "Caelestia desktop shell";
      After = ["hyprland-session.target"];
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "on-failure";
      Slice = "app-graphical.slice";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
