{
  config,
  lib,
  pkgs-stable,
  ...
}: let
  cfg = config.shellix.services.nixos.backup;
in {
  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs.waltz-server = {
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
      encryption.mode = "none";
      repo = "/opt/backup/borg";
      compression = "auto,zstd";
      startAt = "06:00";
      prune.keep = {
        within = "1d"; # Keep all archives from the last day
        daily = 7; # Keep for one week
        weekly = 4; # Keep for one month
        monthly = 6; # Keep monthly backup for half-year
      };
      preHook = ''
        ${pkgs-stable.sudo}/bin/sudo -u postgres ${pkgs-stable.postgresql}/bin/pg_dumpall > /tmp/pg_db-dump
      '';
    };
  };
}
