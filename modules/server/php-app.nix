{
    lib,
    config,
    pkgs-stable,
    ...
}: let
    cfg = config.shellix.server.phpApps;
in {
    options.shellix.server.phpApps = {
        enable = lib.mkEnableOption "the Shellix PHP application server hosting layer";

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

                    domain = lib.mkOption {
                        type = lib.types.str;
                        description = "Hostname for the nginx virtualHost.";
                        example = "myapp.local";
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
        # 1. Automatically enable Nginx if the entire block is active
        services.nginx.enable = true;

        # 2. Build the users block dynamically
        users.users = lib.mapAttrs' (name: app:
            lib.nameValuePair name (lib.mkIf app.enable {
                isSystemUser = true;
                group = name;
                description = "${name} PHP application user";
            }))
        cfg.apps;

        # 3. Build the groups block dynamically
        users.groups = lib.mapAttrs' (name: app: lib.nameValuePair name (lib.mkIf app.enable {})) cfg.apps;

        # 4. Build the Nginx Virtual Hosts dynamically
        services.nginx.virtualHosts = lib.mapAttrs' (name: app: let
            # Inline derivation generation safely inside the evaluation loop
            appPackage = pkgs-stable.stdenv.mkDerivation {
                pname = name;
                inherit (app) version src patches;
                installPhase = "mkdir -p $out && cp -r . $out/ && chmod -R a+rX $out";
                dontBuild = true;
                dontConfigure = true;
                dontFixup = true;
            };
        in
            lib.nameValuePair app.domain (lib.mkIf app.enable {
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

        # 5. Build the PHP-FPM Pools dynamically
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
