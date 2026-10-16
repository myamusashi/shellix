{
    lib,
    config,
    pkgs-stable,
    ...
}: {
    config = lib.mkIf config.shellix.server.vaultwarden.enable {
        services.vaultwarden = {
            enable = true;
            package = pkgs-stable.vaultwarden;
            webVaultPackage = pkgs-stable.vaultwarden.webvault;
            dbBackend = "sqlite";
            backupDir = "/var/backup/vaultwarden";
            environmentFile = config.sops.secrets.smtp_app_password.path;
            config = {
                DOMAIN = "https://vault.myamusashi.cc";
                SIGNUPS_ALLOWED = true;
                PASSWORD_HINTS_ALLOWED = true;
                MAX_INVALID_LOGINS = 5;
                IP_HEADER = "X-Real-IP";
                ROCKET_ADDRESS = "127.0.0.1";
                ROCKET_PORT = config.shellix.variables.port.VAULTWARDEN;
                ROCKET_LOG = "critical";
                SMTP_HOST = "smtp.gmail.com";
                SMTP_PORT = 587;
                SMTP_SECURITY = "starttls";
                SMTP_FROM = "REDACTED_EMAIL";
                SMTP_FROM_NAME = "Vaultwarden";
                SMTP_USERNAME = "REDACTED_EMAIL";
            };
        };

        services.nginx = {
            enable = true;
            virtualHosts."vault.myamusashi.cc" = {
                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.shellix.variables.port.VAULTWARDEN}";
                    recommendedProxySettings = true;
                    proxyWebsockets = true;
                    extraConfig = ''
                        # Upstream wiki value: attachments + large vault JSON
                        # must not hit nginx's 1M default.
                        client_max_body_size 525M;
                        # Upstream 504 fix: large /api/sync responses can take
                        # a while to serialize on a 2GB host.
                        proxy_connect_timeout 777;
                        proxy_send_timeout 777;
                        proxy_read_timeout 777;
                        send_timeout 777;
                    '';
                };
            };
        };
    };
}
