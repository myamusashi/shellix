{
    lib,
    config,
    pkgs-stable,
    ...
}: {
    config = lib.mkIf config.shellix.services.server.vaultwarden.enable {
        services.vaultwarden = {
            enable = true;
            package = pkgs-stable.vaultwarden;
            webVaultPackage = pkgs-stable.vaultwarden.webvault;
            dbBackend = "sqlite";
            backupDir = "/var/backup/vaultwarden";
            environmentFile = config.sops.secrets.smtp_app_password.path;
            config = {
                DOMAIN = "https://vault.myamusashi.space";

                SIGNUPS_ALLOWED = true;
                PASSWORD_HINTS_ALLOWED = true;
                MAX_INVALID_LOGINS = 5;

                ROCKET_ADDRESS = "127.0.0.1";
                ROCKET_PORT = 8222;

                ROCKET_LOG = "critical";

                SMTP_HOST = "smtp.gmail.com";
                SMTP_PORT = 587;
                SMTP_SECURITY = "starttls";
                SMTP_FROM = "REDACTED_EMAIL";
                SMTP_FROM_NAME = "Vaultwarden";
                SMTP_USERNAME = "REDACTED_EMAIL";
            };
        };

        services.nginx.virtualHosts."vault.myamusashi.com" = {
            locations."/" = {
                proxyPass = "http://127.0.0.1:${toString config.shellix.variables.port.VAULTWARDEN}";
            };
        };
    };
}
