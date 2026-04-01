{
    lib,
    config,
    ...
}: {
    config = lib.mkIf config.shellix.services.home-manager.systemd.shell.enable {
        systemd.user.services.shell = {
            Unit = {
                Description = "Shell widget using quickshell";
                After = ["hyprland-session.target"];
            };
            Service = {
                Type = "exec";
                ExecStart = "shell";
                Restart = "on-failure";
                Slice = "app-graphical.slice";
                Environment = [
                    "QSG_RHI_BACKEND=vulkan"
                ];
            };
            Install = {
                WantedBy = ["hyprland-session.target"];
            };
        };
    };
}
