flakeParts: let
    flakeConfig = flakeParts.config;
in {
    flake.modules.nixos.ocis = {
        config,
        pkgs,
        ...
    }: {
        key = "shellix.nixos.ocis";

        imports = [
            flakeConfig.flake.modules.nixos.servicePorts
        ];

        systemd.tmpfiles.rules = [
            "d /var/lib/ocis 0750 ocis ocis - -"
            "d /var/lib/ocis/config 0750 ocis ocis - -"
            "d /var/lib/ocis/data 0750 ocis ocis - -"
        ];

        security.acme.acceptTerms = true;

        services.ocis = {
            enable = true;
            package = pkgs.ocis_5-bin;
            configDir = "/var/lib/ocis/config";
            address = "127.0.0.1";
            port = config.shellix.ports.ocis;
            url = "https://cloud.myamusashi.cc";
            stateDir = "/var/lib/ocis";
            environment = {
                CS3_ALLOW_INSECURE = "true";
                IDP_ISS = "https://cloud.myamusashi.cc";
                IDP_TLS = "false";
                PROXY_ENABLE_BASIC_AUTH = "true";
                OCIS_INSECURE = "false";
                OCIS_INSECURE_BACKENDS = "true";
                OCIS_LOG_LEVEL = "error";
                TLS_INSECURE = "true";
                TLS_SKIP_VERIFY_CLIENT_CERT = "true";
                WEBDAV_ALLOW_INSECURE = "true";
                NOTIFICATIONS_SMTP_SENDER = "no-reply@myamusashi.cc";
            };
            environmentFile = config.sops.secrets.ocis_secrets_password.path;
        };
    };
}
