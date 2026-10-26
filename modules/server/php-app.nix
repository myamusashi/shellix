{
    lib,
    config,
    pkgs-stable,
    ...
}: let
    cfg = config.shellix.server.phpApps;

    dbApps =
        lib.filterAttrs (
            _: app: app.enable && app.database.enable
        )
        cfg.apps;
in {
    options.shellix.server.phpApps = {
        enable = lib.mkEnableOption "the Shellix PHP application server hosting layer";

        database = {
            user = lib.mkOption {
                type = lib.types.str;
                default = "root";
                description = "Shared MariaDB user for all PHP apps.";
            };

            passwordFile = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                description = ''
                    Path to a file containing the MariaDB password.
                    Use sops-nix or agenix to provide this securely.
                    If null, the user is created with no password (unix socket auth only).
                '';
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
                        description = "fetchFromGitHub result or any derivation containing the PHP source tree.";
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
                        description = "Subdomain for the cloudflare tunnel.";
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
                        default = pkgs-stable.php;
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
                            description = "MariaDB database name. Defaults to the app attribute name.";
                        };

                        sqlFile = lib.mkOption {
                            type = lib.types.nullOr lib.types.path;
                            default = null;
                            description = ''
                                Path to a .sql file to import on first run.
                                The import is skipped if the database already contains tables.
                                Set to null to create an empty database.
                            '';
                            example = "./database/init.sql";
                        };
                    };

                    meta = lib.mkOption {
                        type = lib.types.submodule {
                            options = {
                                description = lib.mkOption {
                                    type = lib.types.str;
                                    default = "PHP web application";
                                };
                                homepage = lib.mkOption {
                                    type = lib.types.str;
                                    default = "";
                                };
                                license = lib.mkOption {
                                    type = lib.types.anything;
                                    default = lib.licenses.unfree;
                                };
                            };
                        };
                        default = {};
                    };
                };
            }));
            default = {};
            description = "Attribute set of PHP applications to deploy.";
        };
    };

    config = lib.mkIf cfg.enable {
        services = {
            nginx.enable = true;

            # Mysql actually already handled on database.nix modules
            mysql = lib.mkIf (dbApps != {}) {
                # Create one database per app that has database.enable = true
                ensureDatabases = lib.mapAttrsToList (_: app: app.database.name) dbApps;
                # Single shared user with grants on every app database
                ensureUsers = [
                    {
                        name = cfg.database.user;
                        ensurePermissions = lib.listToAttrs (
                            lib.mapAttrsToList (
                                _: app:
                                    lib.nameValuePair "${app.database.name}.*" "ALL PRIVILEGES"
                            )
                            dbApps
                        );
                    }
                ];
            };
        };

        shellix.server.cloudflared.ingress = lib.mapAttrs' (
            _: app:
                lib.nameValuePair "${app.subdomain}.myamusashi.cc"
                "http://${app.listenAddress}:${toString app.port}"
        ) (lib.filterAttrs (_: app: app.enable && app.subdomain != "") cfg.apps);

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
                        # Run as the mysql user so we can use socket auth without a password
                        User = "mysql";
                    };

                    script = let
                        mysql = "${pkgs-stable.mariadb}/bin/mysql";
                        dbName = app.database.name;
                        sqlFile = app.database.sqlFile;
                    in ''
                        # Check if any tables already exist in the database
                        TABLE_COUNT=$(${mysql} --user="${cfg.database.user}" \
                            ${lib.optionalString (cfg.database.passwordFile != null)
                            ''--password="$(cat ${cfg.database.passwordFile})"''} \
                            --batch --skip-column-names \
                            --execute="SELECT COUNT(*) FROM information_schema.tables \
                                WHERE table_schema = '${dbName}';" 2>/dev/null || echo "0")

                        if [ "$TABLE_COUNT" -eq "0" ]; then
                            echo "phpapp-db-init[${name}]: Database '${dbName}' is empty, importing ${sqlFile}..."
                            ${mysql} --user="${cfg.database.user}" \
                                ${lib.optionalString (cfg.database.passwordFile != null)
                            ''--password="$(cat ${cfg.database.passwordFile})"''} \
                                "${dbName}" < "${sqlFile}"
                            echo "phpapp-db-init[${name}]: Import complete."
                        else
                            echo "phpapp-db-init[${name}]: Database '${dbName}' already has $TABLE_COUNT table(s), skipping import."
                        fi
                    '';
                }))
        cfg.apps;

        users.users = lib.mapAttrs' (name: app:
            lib.nameValuePair name (lib.mkIf app.enable {
                isSystemUser = true;
                group = name;
                description = "${name} PHP application user";
            }))
        cfg.apps;

        users.groups = lib.mapAttrs' (name: app:
            lib.nameValuePair name (lib.mkIf app.enable {}))
        cfg.apps;

        services.nginx.virtualHosts = lib.mapAttrs' (name: app: let
            appPackage = pkgs-stable.stdenv.mkDerivation {
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
                        include ${pkgs-stable.nginx}/conf/fastcgi_params;
                        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                    '';
                };

                locations."/" = {
                    tryFiles = "$uri $uri/ /index.php?$query_string";
                };
            }))
        cfg.apps;

        services.phpfpm.pools = lib.mapAttrs' (name: app: let
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
                    lib.mapAttrsToList (k: v: "${k} = ${v}") app.phpOptions
                );
            }))
        cfg.apps;
    };
}
