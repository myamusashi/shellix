{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.shellix.services.systemd.user.weather-widget;
in {
  config = lib.mkIf cfg.enable {
    systemd = {
      user = {
        timers.get-weather-data = {
          Unit = {Description = "Timer update data cuaca";};
          Timer = {
            OnCalendar = "*:0/15";
            Persistent = true;
            Unit = "get-weather-data";
          };
          Install = {WantedBy = ["timers.target"];};
        };

        services = {
          get-weather-data = {
            Unit = {Description = "Service mendapatkan data cuaca";};
            Service = {
              Type = "oneshot";
              WorkingDirectory = "/home/myamusashi/Documents/Project/weather";
              Environment = ["UNITS=metric"];
              EnvironmentFile = [
                "${config.sops.secrets.weatherapi.path}"
                "${config.sops.secrets.latitude.path}"
                "${config.sops.secrets.longitude.path}"
              ];
              ExecStart = "${pkgs.writeShellScript "get-weather-data" ''
                ${pkgs.bun}/bin/bun ./weather.js
              ''}";
            };
          };

          weather-widget = {
            Unit = {
              Description = "Weather widget build with quickshell";
              After = ["hyprland-session.target"];
            };
            Service = {
              Type = "exec";
              ExecStart = "${pkgs.quickshell}/bin/qs -c weather";
              Restart = "on-failure";
              Slice = "app-graphical.slice";
            };
            Install = {
              WantedBy = ["hyprland-session.target"];
            };
          };
        };
      };
    };
  };
}
