{config, ...}: {
  systemd.user.services.weather-widget = {
    Unit = {
      Description = "Weather widget build with quickshell";
      After = ["hyprland-session.target"];
    };
    Service = {
      Type = "exec";
      ExecStart = "${config.programs.quickshell.finalPackage}/bin/qs -c weather";
      Restart = "on-failure";
      Slice = "app-graphical.slice";
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };
}
