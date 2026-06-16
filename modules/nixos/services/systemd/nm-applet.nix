{
    lib,
    config,
    pkgs,
    ...
}: {
    config = lib.mkIf config.shellix.services.systemd.nm-applet.enable {
        systemd.services.nm-applet = {
            description = "network manager tray";
            after = ["graphical-session.target"];
            wantedBy = ["graphical-session.target"];
            serviceConfig = {
                Type = "exec";
                ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
                Restart = "on-failure";
                Slice = "app-graphical.slice";
            };
        };
    };
}
