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
        "APIKEY=d12714a4df8707506d6dd7688b3ccdfe"
        "LATITUDE=-6.370009714696153"
        "LONGITUDE=106.7581882506284"
        "UNITS=metric"
      ];
      ExecStart = "${pkgs.writeShellScript "get-weather-data" ''
        ${pkgs.bun}/bin/bun ./weather.js
      ''}";
    };
  };
}
