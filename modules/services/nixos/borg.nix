{
  config,
  lib,
  pkgs-stable,
  ...
}: let
  cfg = config.shellix.services.nixos.backup;

  common-excludes = [
    ".cache"
    "/var/cache"
    "/nix"
    "/var/run"
    "/var/tmp"
    "/var/tmp"
    "*/cache"
    "*/cache2" # firefox
    "*/Cache"
    ".config/Slack/logs"
    ".config/Code/CachedData"
    ".container-diff"
    ".npm/_cacache"
    # Work related dirs
    "*/node_modules"
    "*/_build"
    "*/.tox"
    "*/venv"
    "*/.venv"
  ];
in {
  config = {
    sops.secrets.myamusashi-borg.owner = lib.mkIf cfg.myamusashi.enable "root";
    sops.secrets.waltz-borg.owner = lib.mkIf cfg.waltz.enable "root";

    services.borgbackup.jobs = {
      myamusashi = lib.mkIf cfg.myamusashi.enable {
        repo = "waltz@192.168.18.14:/opt/backup/Stations/myamusashi";
        encryption = {
          passCommand = "${pkgs-stable.coreutils}/bin/cat /var/lib/myamusashi/borg-secret";
          mode = "repokey-blake2";
        };
        compression = "auto,zstd";
        startAt = "Mon *-*-* 23:00:00";
        prune.keep = {
          within = "1d"; # Keep all archives from the last day
          daily = 7; # Keep for one week
          weekly = 4; # Keep for one month
          monthly = 6; # Keep monthly backup for half-year
        };
        paths = [
          "/etc/ssh"
          "/etc/NetworkManager/system-connections"
          "/home/myamusashi"
          "/var/lib"
        ];
        exclude =
          common-excludes
          ++ [
            "*/Steam"
          ];
      };
      waltz-server = lib.mkIf cfg.waltz.enable {
        encryption.mode = "repokey-blake2";
        compression = "auto,zstd";
        startAt = "01:00";
        prune.keep = {
          within = "1d"; # Keep all archives from the last day
          daily = 7; # Keep for one week
          weekly = 4; # Keep for one month
          monthly = 6; # Keep monthly backup for half-year
        };
        repo = "/opt/backup/Stations/waltz";
        exclude =
          common-excludes
          ++ [
            "*/external"
          ];

        paths = [
          "/var/lib/containers"
          "/var/lib/docker"
          "/var/lib/forgejo"
          "/var/lib/grafana"
          "/var/lib/mysql"
          "/var/lib/nextcloud"
          "/var/lib/postgresql"
          "/var/lib/prometheus2"
          "/var/lib/redis"
          "/var/lib/redis-nextcloud"
          "/var/lib/systemd"
          "/var/lib/vaultwarden"
          "/opt/Stirling-PDF"
          "/etc/ssh"
          "/etc/NetworkManager/system-connections"
          "/home/forgejo-runner"
          "/tmp/pg_db-dump"
        ];
        encryption.passCommand = "${pkgs-stable.coreutils}/bin/cat ${config.sops.secrets.waltz-borg.path}";
        preHook = ''
          ${pkgs-stable.sudo}/bin/sudo -u postgres ${pkgs-stable.postgresql}/bin/pg_dumpall > /tmp/pg_db-dump
        '';
      };
    };
  };
}
