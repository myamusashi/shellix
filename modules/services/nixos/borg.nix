{
  config,
  lib,
  pkgs-stable,
  ...
}: let
  cfg = config.shellix.services.nixos.backup;

  standardSetupBackup = {
    encryption.mode = "repokey-blake2";
    compression = "auto,zstd";
    startAt = "05:00";
    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7; # Keep for one week
      weekly = 4; # Keep for one month
      monthly = 6; # Keep monthly backup for half-year
    };
  };
  common-excludes = [
    ".cache"
    "/var/cache"
    "/var/run"
    "/var/tmp"
    "/var/tmp"
    "*/cache2" # firefox
    "*/Cache"
    ".config/Slack/logs"
    ".config/Code/CachedData"
    ".container-diff"
    ".npm/_cacache"
    # Work related dirs
    "*/node_modules"
    "*/bower_components"
    "*/_build"
    "*/.tox"
    "*/venv"
    "*/.venv"
  ];
in {
  config = {
    services.borgbackup.jobs = {
      myamusashi = lib.mkIf cfg.myamusashi.enable {
        inherit standardSetupBackup;
        startAt = lib.mkForce "Mon, *-*-* 05:00:00";
        paths = [
          "/home/myamusashi"
        ];
        exclude = common-excludes ++ [];
        environment = {
          BORG_RSH = "ssh -i /home/myamusashi/.ssh/id_rsa";
        };
        encryption.passCommand = "${pkgs-stable.coreutils}/bin/cat ${config.sops.secrets.myamusashi-borg.path}";
        repo = "ssh://waltz@192.168.18.14:/opt/backup/Stations/myamusashi";
      };
      waltz-server = lib.mkIf cfg.waltz.enable {
        inherit standardSetupBackup;
        repo = "/opt/backup/Stations/waltz";
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
