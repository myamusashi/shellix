{
  config,
  pkgs,
  lib,
  ...
}: {
  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;
    port = 5500;
    secretKeyFile = config.sops.secrets.nix-serve_secrets.path;
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["nextcloud"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 4032;
        domain = "dash.myamusashi.com";
        root_url = "http://dash.myamusashi.com";
      };
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = ["systemd"];
    extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi"];
  };

  services.prometheus = {
    enable = true;
    port = 9090;
    globalConfig.scrape_interval = "10s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        bind-address = "0.0.0.0";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/nextcloud 0750 nextcloud nextcloud - -"
    "d /var/lib/nextcloud/config 0750 nextcloud nextcloud - -"
    "d /var/lib/nextcloud/data 0750 nextcloud nextcloud - -"
  ];
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = "cloud.myamusashi.com";
    config = {
      adminpassFile = config.sops.secrets.nextcloud_admin_pass.path;
      dbtype = "pgsql";
      adminuser = "admin";
    };
    settings = {
      trusted_domains = [
        "cloud.myamusashi.space"
      ];
    };
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks notes;
    };
    database.createLocally = true;
    configureRedis = true;
    autoUpdateApps.enable = true;
    extraAppsEnable = true;
  };

  services.phpfpm.pools.phpmyadmin = {
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

  services.nginx = {
    enable = true;

    virtualHosts = let
      configFile = pkgs.writeText "config.inc.php" ''
        <?php
        /* Authentication type */
        $cfg['Servers'][1]['auth_type'] = 'http';
        /* Server parameters */
        $cfg['Servers'][1]['host'] = 'localhost';
        $cfg['Servers'][1]['compress'] = false;
        $cfg['Servers'][1]['AllowNoPassword'] = false;
      '';
      phpmyadminPkg = pkgs.callPackage ./pkg.nix {inherit configFile;};
    in {
      "cloud.myamusashi.com".listen = [
        {
          addr = "127.0.0.1";
          port = 9010;
        }
      ];
      "dash.myamusashi.com" = {
        locations."/" = {
          proxyPass = "http://0.0.0.0:4032";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
      "pma.myamusashi.com" = {
        root = phpmyadminPkg;

        listen = [
          {
            addr = "127.0.0.1";
            port = 9000;
          }
        ];

        locations."/" = {
          index = "index.html index.php";
          tryFiles = "$uri $uri/ =404";
        };

        locations."~ \\.php$" = {
          extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.phpmyadmin.socket};
            fastcgi_index index.php;
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
          '';
        };

        extraConfig = ''
          autoindex off;

          location ~ /\. {
            deny all;
          }

          add_header X-Frame-Options DENY;
          add_header X-Content-Type-Options nosniff;
        '';
      };
    };
  };

  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      server = {
        PROTOCOL = "http+unix";
        DOMAIN = "git.myamusashi.space";
        ROOT_URL = "https://git.myamusashi.space";
        HTTP_ADDR = "/run/forgejo/forgejo.sock";
        HTTP_PORT = 3000;
        SSH_DOMAIN = "git.myamusashi.space";
      };
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
      session = {
        COOKIE_SECURE = true;
      };
      "markup.jupyter" = {
        ENABLED = true;
        FILE_EXTENSIONS = ".ipynb";
        RENDER_COMMAND = "${pkgs.python312Packages.nbconvert}/bin/jupyter-nbconvert --to html --stdout";
        IS_INPUT_FILE = true;
      };
    };
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "waltz";

  services.logind.lidSwitchExternalPower = "ignore";

  services.vsftpd = {
    enable = true;
    writeEnable = true;
    localUsers = true;
    localRoot = "/var/ftp";
    extraConfig = ''
      local_umask=007
    '';
  };
}
