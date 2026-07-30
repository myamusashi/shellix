{
    lib,
    config,
    pkgs,
    ...
}: {
    config = lib.mkIf config.shellix.server.ocis.enable {
        systemd.tmpfiles.rules = [
            "d /var/lib/ocis 0750 ocis ocis - -"
            "d /var/lib/ocis/config 0750 ocis ocis - -"
            "d /var/lib/ocis/data 0750 ocis ocis - -"
        ];

        services.ocis = {
            enable = true;
            package = pkgs.ocis_5-bin;
            configDir = "/var/lib/ocis/config";
            address = "127.0.0.1";
            port = config.shellix.variables.port.OCIS;
            url = "https://cloud.myamusashi.com";
            stateDir = "/var/lib/ocis";
            environment = {
                OCIS_INSECURE = "true";
                PROXY_ENABLE_BASIC_AUTH = "true";
            };
        };
    };
}
