{
    config,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.services.samba.enable {
        services.samba = {
            enable = true;
            openFirewall = true;
            settings = {
                global."map to guest" = "never";
                public = {
                    path = "/home/myamusashi/Public";
                    comment = "myamusashi public share";
                    browseable = "yes";
                    "read only" = "no";
                    "guest ok" = "no";
                    "valid users" = "myamusashi";
                };
            };
        };

        systemd.tmpfiles.rules = [
            "d /home/myamusashi/Public 0755 myamusashi users - -"
        ];
    };
}
