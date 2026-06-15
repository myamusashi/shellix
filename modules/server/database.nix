{
    config,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.server.database.enable {
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
        #
        # services.mysql = {
        #     enable = false;
        #     package = pkgs.mariadb;
        #     settings.mysqld."bind-address" = "0.0.0.0";
        # };
    };
}
