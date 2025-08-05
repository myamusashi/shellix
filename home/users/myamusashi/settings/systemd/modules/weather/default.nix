{pkgs, ...}: {
  imports = [
    ./widget.nix
  ];
  systemd.user.timers.get-weather-data = {
    Unit = {Description = "Timer update data cuaca";};
    Timer = {
      OnCalendar = "*:0/15";
      Persistent = true;
      Unit = "get-weather-data";
    };
    Install = {WantedBy = ["timers.target"];};
  };

  systemd.user.services.get-weather-data = {
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
}
