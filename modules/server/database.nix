{
    config,
    lib,
    pkgs-stable,
    ...
}: {
    config = lib.mkIf config.shellix.server.database.enable {
        services.postgresql = {
            enable = true;
            ensureDatabases = ["forgejo"];
        };

        services.mysql = {
            enable = true;
            package = pkgs-stable.mariadb;
            settings.mysqld."bind-address" = "0.0.0.0";
        };
    };
}
