{pkgs, ...}: {
  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "Caelestia desktop shell";
      After = ["hyprland-session.target"];
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      ExecStop = "${pkgs.swww}/bin/swww kill";
      Restart = "${pkgs.swww}/bin/swww kill | ${pkgs.swww}/bin/swww-daemon &";
      Slice = "app-graphical.slice";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
