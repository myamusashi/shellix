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
      config = {
        DOMAIN = "https://vault.myamusashi.space";
        SIGNUPS_ALLOWED = false;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;

        ROCKET_LOG = "critical";
      };
    };

    services.nginx.virtualHosts."vault.myamusashi.com" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.shellix.variables.port.VAULTWARDEN}";
      };
    };
  };
}
