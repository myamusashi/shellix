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
    secretKeyFile = config.sops.secrets.nix-serve_secret.path;
  };

  services.atticd = {
    enable = false;
    environmentFile = "/etc/attic.env";
    settings = {
      listen = "[::1]:4040";
      database = {
        url = "postgresql:///attic?host=/run/postgresql";
      };
    };
  };

  services.httpd = {
    enable = true;
    enablePHP = true;
    adminAddr = "admin@email.tld";

    extraConfig = ''
      DirectoryIndex index.html index.php
    '';

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
      "pma.myamusashi.com" = {
        documentRoot = phpmyadminPkg;
        extraConfig = ''
          <Directory "${phpmyadminPkg}">
            Options -Indexes
          </Directory>
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
