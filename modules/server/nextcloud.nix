{
    lib,
    config,
    pkgs,
    ...
}: {
    config = lib.mkIf config.shellix.server.nextcloud.enable {
        systemd.tmpfiles.rules = [
            "d /var/lib/nextcloud 0750 nextcloud nextcloud - -"
            "d /var/lib/nextcloud/config 0750 nextcloud nextcloud - -"
            "d /var/lib/nextcloud/data 0750 nextcloud nextcloud - -"
        ];

        services.nextcloud = {
            enable = true;
            package = pkgs.nextcloud32; # Disarankan menggunakan versi terbaru
            hostName = "cloud.myamusashi.com";
            config = {
                adminpassFile = config.sops.secrets.nextcloud_admin_pass.path;
                dbtype = "pgsql";
                adminuser = "admin";
            };
            settings.trusted_domains = ["cloud.myamusashi.cc"];
            extraApps = with config.services.nextcloud.package.packages.apps; {inherit contacts calendar tasks notes;};
            database.createLocally = true;
            configureRedis = true;
            autoUpdateApps.enable = true;
            extraAppsEnable = true;
        };

        services.nginx.virtualHosts."cloud.myamusashi.com".listen = [
            {
                addr = "0.0.0.0";
                port = 9010;
            }
        ];
    };
}
