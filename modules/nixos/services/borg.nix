{
    config,
    lib,
    pkgs,
    pkgs-stable,
    ...
}: let
    cfg = config.shellix.services.backup;

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
        "*/.direnv"
    ];
in {
    config = {
        services.borgbackup.jobs = {
            myamusashi = lib.mkIf cfg.myamusashi.enable {
                repo = "waltz@10.88.0.1:/opt/backup/Stations/myamusashi";
                environment = {
                    BORG_RSH = "ssh -i /root/.ssh/id_ed25519 -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new";
                    BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
                };
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
                    "/home/myamusashi/Kde-connect/"
                    "/home/myamusashi/Games"
                    "/home/myamusashi/Pictures"
                    "/home/myamusashi/.config"
                    # On-disk backing of the tmpfs Zen profile (the live profile path is a symlink into /dev/shm)
                    "/home/myamusashi/.zen/kxhdnjqx.zen/chrome/"
                    "/home/myamusashi/.cloudflared"
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
                encryption = {
                    mode = "repokey-blake2";
                    passCommand = "${pkgs-stable.coreutils}/bin/cat ${config.sops.secrets.waltz-borg.path}";
                };
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

                paths =
                    [
                        "/etc/ssh"
                        "/var/lib/systemd"
                    ]
                    ++ lib.optional config.networking.networkmanager.enable "/etc/NetworkManager/system-connections"
                    ++ lib.optional config.shellix.server.wireguard.enable "/etc/wireguard-keys"
                    ++ lib.optional config.virtualisation.podman.enable "/var/lib/containers"
                    ++ lib.optional config.virtualisation.docker.enable "/var/lib/docker"
                    ++ lib.optional config.services.forgejo.enable "/var/lib/forgejo"
                    ++ lib.optional config.services.grafana.enable "/var/lib/grafana"
                    ++ lib.optional config.services.mysql.enable "/var/lib/mysql"
                    ++ lib.optional config.services.ocis.enable "/var/lib/ocis"
                    ++ lib.optional config.services.prometheus.enable "/var/lib/prometheus2"
                    ++ lib.optional config.services.vaultwarden.enable "/var/lib/vaultwarden"
                    ++ lib.optional config.shellix.services.systemd.stirling.enable "/opt/Stirling-PDF"
                    ++ lib.optional config.services.postgresql.enable "/tmp/pg_db-dump";
                preHook = lib.optionalString config.services.postgresql.enable ''
                    (umask 077 && ${pkgs.sudo}/bin/sudo -u postgres ${config.services.postgresql.package}/bin/pg_dumpall > /tmp/pg_db-dump)
                '';
                postHook = lib.optionalString config.services.postgresql.enable ''
                    rm -f /tmp/pg_db-dump
                '';
            };
        };
    };
}
