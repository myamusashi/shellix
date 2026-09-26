{
    lib,
    config,
    pkgs,
    ...
}: {
    config = lib.mkIf config.shellix.server.phpmyadmin.enable {
        services = {
            nginx = {
                enable = true;
                virtualHosts."pma.myamusashi.com" = let
                    configFile = pkgs.writeText "config.inc.php" ''
                        <?php
                        /* Authentication type */
                        $cfg['Servers'][1]['auth_type'] = 'http';
                        /* Server parameters */
                        $cfg['Servers'][1]['host'] = 'localhost';
                        $cfg['Servers'][1]['compress'] = false;
                        $cfg['Servers'][1]['AllowNoPassword'] = false;
                    '';
                    phpmyadminPkg = pkgs.callPackage ./external/pma-pkg.nix {inherit configFile;};
                in {
                    root = phpmyadminPkg;
                    listen = [
                        {
                            addr = "127.0.0.1";
                            port = 9000;
                        }
                    ];
                    extraConfig = ''
                        index index.php index.html;
                    '';
                    locations."~ \\.php$".extraConfig = ''
                        fastcgi_split_path_info ^(.+\.php)(/.+)$;
                        fastcgi_pass unix:${config.services.phpfpm.pools.phpmyadmin.socket};
                        fastcgi_index index.php;
                        include ${pkgs.nginx}/conf/fastcgi_params;
                        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                    '';
                };
            };
            phpfpm.pools.phpmyadmin = {
                user = "nginx";
                settings = {
                    "pm" = "dynamic";
                    "listen.owner" = "nginx";
                    "pm.max_children" = 32;
                    "pm.start_servers" = 2;
                    "pm.min_spare_servers" = 2;
                    "pm.max_spare_servers" = 4;
                    "pm.max_requests" = 500;
                };
            };
        };
    };
}
