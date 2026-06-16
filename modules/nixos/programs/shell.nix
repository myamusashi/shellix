{
    inputs,
    pkgs,
    config,
    lib,
    ...
}: let
    cfg = config.shellix.programs.shell;
in {
    config = lib.mkIf cfg.enable {
        systemd.user.services.quickshell-shell = {
            description = "vast-shell widget built on quickshell";
            wantedBy = ["graphical-session.target"];
            after = ["graphical-session.target"];
            partOf = ["graphical-session.target"];

            serviceConfig = {
                Type = "simple";
                ExecStart = "${inputs.shell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/shell";
                Restart = "on-failure";
                RestartSec = "5s";
                Environment = [
                    "WAYLAND_DISPLAY=wayland-1"
                    "XDG_RUNTIME_DIR=/run/user/%U"
                    "QT_QPA_PLATFORM=wayland"
                    "DISPLAY=:0"
                ];
            };
        };
    };
}
