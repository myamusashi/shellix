{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: {
  config = lib.mkIf config.shellix.services.systemd.user.shell.enable {
    systemd.user.services.shell = {
      Unit = {
        Description = "Shell widget using quickshell";
        After = ["hyprland-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = "${pkgs.quickshell}/bin/qs -c lock";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };
      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };
  };
}
