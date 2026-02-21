{
    config,
    lib,
    pkgs,
    ...
}: {
    config = lib.mkIf config.shellix.services.server.database.enable {
        services.postgresql = {
            enable = true;
            ensureDatabases = ["nextcloud" "forgejo"];
            ensureUsers = [
                {
                    name = "nextcloud";
                    ensureDBOwnership = true;
                }
            ];
        };

        services.mysql = {
            enable = true;
            package = pkgs.mariadb;
            settings.mysqld."bind-address" = "0.0.0.0";
        };
    };
}
