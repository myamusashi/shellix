{
    flake.modules.nixos.database = {pkgs, ...}: {
        key = "shellix.nixos.database";

        services = {
            postgresql = {
                enable = true;
                ensureDatabases = ["forgejo"];
            };

            mysql = {
                enable = true;
                package = pkgs.mariadb;
                settings.mysqld."bind-address" = "0.0.0.0";
            };
        };
    };
}
