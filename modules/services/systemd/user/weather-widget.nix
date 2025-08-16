{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.shellix.services.systemd.user.weather-widget.enable {
    systemd = {
      user.timers.get-weather-data = {
        Unit = {Description = "Timer update data cuaca";};
        Timer = {
          OnCalendar = "*:0/15";
          Persistent = true;
          Unit = "get-weather-data";
        };
        Install = {WantedBy = ["timers.target"];};
      };

      user.services.get-weather-data = {
        Unit = {Description = "Service mendapatkan data cuaca";};
        Service = {
          Type = "oneshot";
          WorkingDirectory = "/home/myamusashi/Documents/Project/weather";
          Environment = [
            "APIKEY=REDACTED_WEATHER_API_KEY"
            "LATITUDE=REDACTED_LATITUDE"
            "LONGITUDE=REDACTED_LONGITUDE"
            "UNITS=metric"
          ];
          ExecStart = "${pkgs.writeShellScript "get-weather-data" ''
            ${pkgs.bun}/bin/bun ./weather.js
          ''}";
        };
      };

      user.services.weather-widget = {
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
}
