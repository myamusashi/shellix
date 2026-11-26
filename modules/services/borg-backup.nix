let
    commonExcludes = [
        ".cache"
        "/var/cache"
        "/nix"
        "/var/run"
        "/var/tmp"
        "*/cache"
        "*/cache2"
        "*/Cache"
        ".config/Slack/logs"
        ".config/Code/CachedData"
        ".container-diff"
        ".npm/_cacache"
        "*/node_modules"
        "*/_build"
        "*/.tox"
        "*/venv"
        "*/.venv"
        "*/.direnv"
    ];

    defaultPruneKeep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = 6;
    };
in {
    flake.modules.nixos.borgBackupMyamusashi = {
        config,
        pkgs,
        ...
    }: {
        key = "shellix.nixos.borgBackupMyamusashi";

        services.borgbackup.jobs.myamusashi = {
            repo = "waltz@10.88.0.1:/opt/backup/Stations/myamusashi";
            environment = {
                BORG_RSH = "ssh -i /root/.ssh/id_ed25519 -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new";
                BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
            };
            encryption = {
                passCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.myamusashi-borg.path}";
                mode = "repokey-blake2";
            };
            compression = "auto,zstd";
            startAt = "Mon *-*-* 23:00:00";
            prune.keep = defaultPruneKeep;
            paths = [
                "/etc/ssh"
                "/etc/wireguard-keys"
                "/etc/NetworkManager/system-connections"
                "/home/myamusashi/Desktop"
                "/home/myamusashi/Documents"
                "/home/myamusashi/Downloads"
                "/home/myamusashi/Games"
                "/home/myamusashi/Pictures"
                "/home/myamusashi/.config"
                # On-disk backing of the tmpfs Zen profile (live profile path is symlinked into /dev/shm).
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
                commonExcludes
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
    };

    flake.modules.nixos.borgBackupWaltz = {
        config,
        lib,
        pkgs,
        ...
    }: {
        key = "shellix.nixos.borgBackupWaltz";

        services.borgbackup.jobs.waltz-server = {
            encryption = {
                mode = "repokey-blake2";
                passCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.waltz-borg.path}";
            };
            compression = "auto,zstd";
            startAt = "01:00";
            prune.keep = defaultPruneKeep;
            repo = "/opt/backup/Stations/waltz";
            exclude =
                commonExcludes
                ++ [
                    "*/external"
                ];

            paths =
                [
                    "/etc/ssh"
                    "/var/lib/systemd"
                ]
                ++ lib.optional config.networking.networkmanager.enable "/etc/NetworkManager/system-connections"
                ++ lib.optional (config.networking.wg-quick.interfaces != {}) "/etc/wireguard-keys"
                ++ lib.optional config.virtualisation.podman.enable "/var/lib/containers"
                ++ lib.optional config.virtualisation.docker.enable "/var/lib/docker"
                ++ lib.optional config.microvm.host.enable "/var/lib/microvms"
                ++ lib.optional config.services.forgejo.enable "/var/lib/forgejo"
                ++ lib.optional config.services.mysql.enable "/var/lib/mysql"
                ++ lib.optional config.services.ocis.enable "/var/lib/ocis"
                ++ lib.optional config.services.vaultwarden.enable "/var/lib/vaultwarden"
                ++ lib.optional config.services.postgresql.enable "/tmp/pg_db-dump";

            preHook = lib.optionalString config.services.postgresql.enable ''
                (umask 077 && ${pkgs.sudo}/bin/sudo -u postgres ${config.services.postgresql.package}/bin/pg_dumpall > /tmp/pg_db-dump)
            '';
            postHook = lib.optionalString config.services.postgresql.enable ''
                rm -f /tmp/pg_db-dump
            '';
        };
    };
}
