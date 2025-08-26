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
    services.borgbackup.jobs = {
      myamusashi = lib.mkIf cfg.myamusashi.enable {
        repo = "waltz@192.168.18.14:/opt/backup/Stations/myamusashi";
        encryption = {
          passCommand = "${pkgs-stable.coreutils}/bin/cat ${config.sops.secrets.myamusashi-borg.path}";
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
          "/etc/wireguard-keys"
          "/etc/NetworkManager/system-connections"
          "/home/myamusashi/apps"
          "/home/myamusashi/Desktop"
          "/home/myamusashi/Documents"
          "/home/myamusashi/Downloads"
          "/home/myamusashi/NetBeansProjects"
          "/home/myamusashi/Pictures"
          "/home/myamusashi/.config"
          "/home/myamusashi/.zen/h2lo302h.zen"
          "/home/myamusashi/.android"
          "/home/myamusashi/.password-store"
          "/home/myamusashi/.dots"
          "/home/myamusashi/.gitconfig"
          "/home/myamusashi/.git-credentials"
          "/home/myamusashi/.mysql/workbench"
          "/home/myamusashi/.local/share/fish"
          "/home/myamusashi/.wine"
          "/home/myamusashi/.face"
          "/home/myamusashi/.face.icon"
          "/home/myamusashi/.ssh"
          "/var/lib"
        ];
        exclude =
          common-excludes
          ++ [
            "*/Steam"
            "*/.steam"
            "/var/lib/fwupd"
            "/var/lib/geoclue"
            "/var/lib/misc"
            "/var/lib/power-profiles-daemon"
            "/var/lib/systemd"
            "/var/lib/udisks2"
            "/var/lib/upower"
            "/var/lib/myamusashi"
            "/var/lib/waltz"
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
          "/etc/wireguard-keys"
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
