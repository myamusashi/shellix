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
                CS3_ALLOW_INSECURE = "true";
                GATEWAY_STORAGE_USERS_MOUNT_ID = "123";
                GRAPH_APPLICATION_ID = "1234";
                IDP_ISS = "https://localhost:${toString config.shellix.variables.port.OCIS}";
                IDP_TLS = "false";
                OCIS_INSECURE = "true";
                OCIS_INSECURE_BACKENDS = "true";
                OCIS_LOG_LEVEL = "error";
                OCIS_MACHINE_AUTH_API_KEY = "foo";
                OCIS_MOUNT_ID = "123";
                OCIS_SERVICE_ACCOUNT_ID = "foo";
                OCIS_STORAGE_USERS_MOUNT_ID = "123";
                OCIS_SYSTEM_USER_API_KEY = "foo";
                OCIS_SYSTEM_USER_ID = "123";
                STORAGE_USERS_MOUNT_ID = "123";
                TLS_INSECURE = "true";
                TLS_SKIP_VERIFY_CLIENT_CERT = "true";
                WEBDAV_ALLOW_INSECURE = "true";
            };
            environmentFile = config.sops.secrets.ocis_secrets_password.path;
        };
    };
}
