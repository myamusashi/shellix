flakeParts: let
    flakeConfig = flakeParts.config;
in {
    flake.modules.nixos.phpApps = {
        config,
        lib,
        pkgs,
        ...
    }: let
        phpAppsConfig = config.shellix.phpApps;
        databaseApps = lib.filterAttrs (_: app: app.enable && app.database.enable) phpAppsConfig.apps;
    in {
        key = "shellix.nixos.phpApps";

        imports = [
            flakeConfig.flake.modules.nixos.database
            flakeConfig.flake.modules.nixos.cloudflared
        ];

        options.shellix.phpApps = {
            database = {
                user = lib.mkOption {
                    type = lib.types.str;
                    default = "root";
                    description = "Shared MariaDB user for all PHP apps.";
                };

                passwordFile = lib.mkOption {
                    type = lib.types.nullOr lib.types.path;
                    default = null;
                    description = "Optional path to a file containing the MariaDB password (null uses unix socket auth).";
                };
            };

            apps = lib.mkOption {
                type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
                    options = {
                        enable = lib.mkEnableOption "this individual PHP application";

                        version = lib.mkOption {
                            type = lib.types.str;
                            default = "0.1.0";
                        };

                        src = lib.mkOption {
                            type = lib.types.package;
                            description = "Derivation containing the PHP source tree.";
                        };

                        patches = lib.mkOption {
                            type = lib.types.listOf lib.types.path;
                            default = [];
                        };

                        vHostDomain = lib.mkOption {
                            type = lib.types.str;
                            description = "Hostname for the nginx virtualHost.";
                            example = "myapp.local";
                        };

                        subdomain = lib.mkOption {
                            type = lib.types.str;
                            default = "";
                            description = "Subdomain for the Cloudflare tunnel.";
                            example = "myapp";
                        };

                        listenAddress = lib.mkOption {
                            type = lib.types.str;
                            default = "127.0.0.1";
                        };

                        port = lib.mkOption {
                            type = lib.types.port;
                            default = 80;
                        };

                        enableSSL = lib.mkOption {
                            type = lib.types.bool;
                            default = false;
                        };

                        phpPackage = lib.mkOption {
                            type = lib.types.package;
                            default = pkgs.php;
                        };

                        phpExtensions = lib.mkOption {
                            type = lib.types.functionTo (lib.types.listOf lib.types.package);
                            default = _: [];
                        };

                        phpOptions = lib.mkOption {
                            type = lib.types.attrsOf lib.types.str;
                            default = {
                                upload_max_filesize = "64M";
                                post_max_size = "64M";
                                memory_limit = "256M";
                            };
                        };

                        fpmSettings = lib.mkOption {
                            type = lib.types.attrsOf lib.types.str;
                            default = {
                                "pm" = "dynamic";
                                "pm.max_children" = "5";
                                "pm.start_servers" = "2";
                                "pm.min_spare_servers" = "1";
                                "pm.max_spare_servers" = "3";
                            };
                        };

                        database = {
                            enable = lib.mkEnableOption "MariaDB database for this app";

                            name = lib.mkOption {
                                type = lib.types.str;
                                default = name;
                                description = "MariaDB database name.";
                            };

                            sqlFile = lib.mkOption {
                                type = lib.types.nullOr lib.types.path;
                                default = null;
                                description = "Optional .sql file imported on first run when the database is empty.";
                            };
                        };
                    };
                }));
                default = {};
                description = "Attribute set of PHP applications to deploy.";
            };
        };

        config = {
            services = {
                nginx = {
                    enable = true;
                    virtualHosts = lib.mapAttrs' (name: app: let
                        appPackage = pkgs.stdenv.mkDerivation {
                            pname = name;
                            inherit (app) version src patches;
                            installPhase = "mkdir -p $out && cp -r . $out/ && chmod -R a+rX $out";
                            dontBuild = true;
                            dontConfigure = true;
                            dontFixup = true;
                        };
                    in
                        lib.nameValuePair app.vHostDomain (lib.mkIf app.enable {
                            listen = [
                                {
                                    addr = app.listenAddress;
                                    inherit (app) port;
                                }
                            ];
                            root = "${appPackage}";
                            enableACME = app.enableSSL;
                            forceSSL = app.enableSSL;

                            locations."~ \\.php$" = {
                                extraConfig = ''
                                    fastcgi_pass unix:/run/phpfpm/${name}.sock;
                                    fastcgi_index index.php;
                                    include ${pkgs.nginx}/conf/fastcgi_params;
                                    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                                '';
                            };

                            locations."/" = {
                                tryFiles = "$uri $uri/ /index.php?$query_string";
                            };
                        }))
                    phpAppsConfig.apps;
                };

                mysql = lib.mkIf (databaseApps != {}) {
                    ensureDatabases = lib.mapAttrsToList (_: app: app.database.name) databaseApps;
                    ensureUsers = [
                        {
                            name = phpAppsConfig.database.user;
                            ensurePermissions = lib.listToAttrs (
                                lib.mapAttrsToList (
                                    _: app:
                                        lib.nameValuePair "${app.database.name}.*" "ALL PRIVILEGES"
                                )
                                databaseApps
                            );
                        }
                    ];
                };

                phpfpm.pools = lib.mapAttrs' (name: app: let
                    phpWithExtensions = app.phpPackage.withExtensions (
                        {
                            all,
                            enabled,
                        }:
                            enabled ++ app.phpExtensions all
                    );
                in
                    lib.nameValuePair name (lib.mkIf app.enable {
                        user = name;
                        group = name;
                        phpPackage = phpWithExtensions;
                        settings = app.fpmSettings // {"listen.owner" = "nginx";};
                        phpOptions = lib.concatStringsSep "\n" (
                            lib.mapAttrsToList (optionName: optionValue: "${optionName} = ${optionValue}") app.phpOptions
                        );
                    }))
                phpAppsConfig.apps;
            };

            shellix.cloudflared.ingress = lib.mapAttrs' (
                _: app:
                    lib.nameValuePair "${app.subdomain}.myamusashi.cc"
                    "http://${app.listenAddress}:${toString app.port}"
            ) (lib.filterAttrs (_: app: app.enable && app.subdomain != "") phpAppsConfig.apps);

            systemd.services = lib.mapAttrs' (name: app:
                lib.nameValuePair "phpapp-db-init-${name}" (lib.mkIf (
                        app.enable && app.database.enable && app.database.sqlFile != null
                    ) {
                        description = "Initialize MariaDB database for PHP app: ${name}";
                        after = ["mysql.service"];
                        requires = ["mysql.service"];
                        wantedBy = ["multi-user.target"];

                        serviceConfig = {
                            Type = "oneshot";
                            RemainAfterExit = true;
                            User = "mysql";
                        };

                        script = let
                            mysqlBinary = "${pkgs.mariadb}/bin/mysql";
                            databaseName = app.database.name;
                            inherit (app.database) sqlFile;
                        in ''
                            TABLE_COUNT=$(${mysqlBinary} --user="${phpAppsConfig.database.user}" \
                                ${lib.optionalString (phpAppsConfig.database.passwordFile != null)
                                ''--password="$(cat ${phpAppsConfig.database.passwordFile})"''} \
                                --batch --skip-column-names \
                                --execute="SELECT COUNT(*) FROM information_schema.tables \
                                    WHERE table_schema = '${databaseName}';" 2>/dev/null || echo "0")

                            if [ "$TABLE_COUNT" -eq "0" ]; then
                                ${mysqlBinary} --user="${phpAppsConfig.database.user}" \
                                    ${lib.optionalString (phpAppsConfig.database.passwordFile != null)
                                ''--password="$(cat ${phpAppsConfig.database.passwordFile})"''} \
                                    "${databaseName}" < "${sqlFile}"
                            fi
                        '';
                    }))
            phpAppsConfig.apps;

            users = {
                users = lib.mapAttrs' (name: app:
                    lib.nameValuePair name (lib.mkIf app.enable {
                        isSystemUser = true;
                        group = name;
                        description = "${name} PHP application user";
                    }))
                phpAppsConfig.apps;

                groups = lib.mapAttrs' (name: app:
                    lib.nameValuePair name (lib.mkIf app.enable {}))
                phpAppsConfig.apps;
            };
        };
    };
}
