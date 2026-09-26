{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.services.kdeconnect;
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.kdePackages.kdeconnect-kde];

        networking.firewall = {
            allowedTCPPortRanges = [
                {
                    from = 1714;
                    to = 1764;
                }
            ];
            allowedUDPPortRanges = [
                {
                    from = 1714;
                    to = 1764;
                }
            ];
        };

        systemd.user.services = {
            kdeconnect = {
                description = "KDE Connect daemon";
                after = ["graphical-session.target"];
                partOf = ["graphical-session.target"];
                wantedBy = ["graphical-session.target"];
                serviceConfig = {
                    ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnectd";
                    Restart = "on-abort";
                };
            };
            kdeconnect-indicator = {
                description = "KDE Connect indicator";
                after = ["graphical-session.target"];
                partOf = ["graphical-session.target"];
                wantedBy = ["graphical-session.target"];
                serviceConfig = {
                    ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator";
                    Restart = "on-abort";
                };
            };
        };
    };
}
