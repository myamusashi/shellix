{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: {
  config = lib.mkIf config.shellix.services.systemd.user.caelestia.enable {
    systemd.user.services.caelestia-shell = {
      Unit = {
        Description = "Caelestia-shell build with quickshell";
        After = ["hyprland-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = "${inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/caelestia-shell";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };
      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };
  };
}
