flakeParts: let
    flakeConfig = flakeParts.config;
in {
    flake.modules.nixos.vaultwarden = {
        config,
        pkgs,
        ...
    }: {
        key = "shellix.nixos.vaultwarden";

        imports = [
            flakeConfig.flake.modules.nixos.servicePorts
        ];

        sops.templates."vaultwarden-smtp.env" = {
            content = ''
                SMTP_FROM=${config.sops.placeholder.gmail_account}
                SMTP_USERNAME=${config.sops.placeholder.gmail_account}
            '';
        };

        services = {
            vaultwarden = {
                enable = true;
                package = pkgs.vaultwarden;
                webVaultPackage = pkgs.vaultwarden.webvault;
                dbBackend = "sqlite";
                backupDir = "/var/backup/vaultwarden";
                environmentFile = [
                    config.sops.secrets.smtp_app_password.path
                    config.sops.templates."vaultwarden-smtp.env".path
                ];
                config = {
                    DOMAIN = "https://vault.myamusashi.cc";
                    SIGNUPS_ALLOWED = false;
                    PASSWORD_HINTS_ALLOWED = true;
                    MAX_INVALID_LOGINS = 5;
                    IP_HEADER = "X-Real-IP";
                    ROCKET_ADDRESS = "127.0.0.1";
                    ROCKET_PORT = config.shellix.ports.vaultwarden;
                    ROCKET_LOG = "critical";
                    SMTP_HOST = "smtp.gmail.com";
                    SMTP_PORT = 587;
                    SMTP_SECURITY = "starttls";
                    SMTP_FROM_NAME = "Vaultwarden";
                };
            };

            nginx = {
                enable = true;
                virtualHosts."vault.myamusashi.cc" = {
                    locations."/" = {
                        proxyPass = "http://127.0.0.1:${toString config.shellix.ports.vaultwarden}";
                        recommendedProxySettings = true;
                        proxyWebsockets = true;
                        extraConfig = ''
                            # Upstream wiki value: attachments and large vault JSON exceed nginx 1M default.
                            client_max_body_size 525M;
                            # Large /api/sync responses can serialize slowly on a 2GB host.
                            proxy_connect_timeout 777;
                            proxy_send_timeout 777;
                            proxy_read_timeout 777;
                            send_timeout 777;
                        '';
                    };
                };
            };
        };
    };
}
