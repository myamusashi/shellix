{
    flake.modules.nixos.foot = {pkgs, ...}: {
        programs.foot.enable = true;

        systemd.user.services.foot-server = {
            description = "running foot terminal server";
            wantedBy = ["graphical-session.target"];
            environment = {
                WAYLAND_DISPLAY = "wayland-1";
            };

            serviceConfig = {
                Type = "simple";
                ExecStart = "${pkgs.foot}/bin/foot --server";
                Restart = "on-failure";
                RestartSec = 5;
            };
        };
    };
}
