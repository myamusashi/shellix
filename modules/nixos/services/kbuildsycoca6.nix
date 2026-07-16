{
    lib,
    config,
    pkgs,
    ...
}: {
    config = lib.mkIf config.shellix.services.kbuildsycoca6.enable {
        systemd.user.services.kbuildsycoca6 = {
            description = "KDE Build System Configuration Cache";
            after = ["graphical-session.target"];
            wantedBy = ["graphical-session.target"];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "${lib.getExe pkgs.kdePackages.kservice}";
            };
        };
    };
}
