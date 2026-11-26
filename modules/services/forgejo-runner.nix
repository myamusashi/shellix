flakeParts: let
    flakeConfig = flakeParts.config;
in {
    flake.modules.nixos.forgejoRunner = {
        config,
        lib,
        pkgs,
        ...
    }: let
        runnerConfig = config.shellix.forgejoRunner;
        yamlFormat = pkgs.formats.yaml {};

        mkRunnerConfig = runnerName: tokenPath: runner:
            yamlFormat.generate "forgejo-runner-${runnerName}.yaml" {
                runner = {
                    file = ".runner";
                    capacity = 1;
                    timeout = "3h";
                    # Kept below TimeoutStopSec (90s) and microvm@ host TimeoutSec (150s)
                    # so the runner can cancel and report in-flight jobs before SIGKILL.
                    shutdown_timeout = "60s";
                    insecure = false;
                    fetch_timeout = "30s";
                    fetch_interval = "2s";
                    report_interval = "1s";
                    inherit (runner) labels;
                };
                cache = {
                    enabled = true;
                    port = 0;
                    proxy_port = 0;
                };
                host.workdir_parent = "/var/lib/forgejo-runner/${runnerName}/work";
                server.connections.default = {
                    inherit (runner) url uuid labels;
                    token_url = "file://${tokenPath}";
                };
            };

        mkRunnerServices = tokenPathFor:
            lib.mapAttrs' (
                name: runner:
                    lib.nameValuePair "forgejo-runner-${name}" {
                        description = "Forgejo Runner — ${name}";
                        after = [
                            "network-online.target"
                            "nix-daemon.socket"
                        ];
                        wants = [
                            "network-online.target"
                            "nix-daemon.socket"
                        ];
                        wantedBy = ["multi-user.target"];

                        environment = {
                            HOME = "/var/lib/forgejo-runner/${name}";
                            NIX_REMOTE = "daemon";
                        };

                        path = [
                            pkgs.bash
                            pkgs.coreutils
                            pkgs.curl
                            pkgs.findutils
                            pkgs.gawk
                            pkgs.git
                            pkgs.gnugrep
                            pkgs.gnused
                            pkgs.gnutar
                            pkgs.gzip
                            pkgs.jq
                            pkgs.nix
                            pkgs.nodejs
                            pkgs.openssh
                            pkgs.unzip
                            pkgs.which
                            pkgs.xz
                            pkgs.zstd
                        ];

                        serviceConfig = {
                            Type = "simple";
                            WorkingDirectory = "/var/lib/forgejo-runner/${name}";
                            StateDirectory = [
                                "forgejo-runner/${name}"
                                "forgejo-runner/${name}/work"
                            ];
                            ExecStart = "${lib.getExe pkgs.forgejo-runner} daemon --config ${mkRunnerConfig name (tokenPathFor name runner) runner}";
                            TimeoutStopSec = "90s";
                            Restart = "on-failure";
                            RestartSec = 5;
                        };
                    }
            )
            runnerConfig.runners;

        guestCleanupScript = pkgs.writeShellApplication {
            name = "forgejo-runner-cleanup";
            runtimeInputs = [
                pkgs.coreutils
                pkgs.findutils
                pkgs.nix
            ];
            text = ''
                retention_days=${toString runnerConfig.microvm.cleanup.retentionDays}

                nix-collect-garbage --delete-older-than "''${retention_days}d"

                for runner_directory in /var/lib/forgejo-runner/*/; do
                    for stale_directory in \
                        "$runner_directory/work" \
                        "$runner_directory/.cache/act" \
                        "$runner_directory/.cache/actcache"; do
                        if [ -d "$stale_directory" ]; then
                            find "$stale_directory" -mindepth 1 -maxdepth 1 \
                                -mtime "+$retention_days" -exec rm -rf {} +
                        fi
                    done
                done
            '';
        };

        secretsPackScript = pkgs.writeShellApplication {
            name = "forgejo-runner-pack-secrets";
            runtimeInputs = [
                pkgs.coreutils
                pkgs.e2fsprogs
                pkgs.util-linux
            ];
            text = ''
                set -euo pipefail
                STATE_DIR="/var/lib/microvms/ci-runner"
                OUT_IMG="$STATE_DIR/ci-secrets.ext4"
                STAGE="$(mktemp -d /tmp/ci-secrets-stage.XXXXXX)"
                trap 'rm -rf "$STAGE"' EXIT

                mkdir -p "$STATE_DIR"
                ${lib.concatStringsSep "\n" (
                    lib.mapAttrsToList (runnerName: runner: ''
                        install -m 0400 ${lib.escapeShellArg runner.tokenFile} "$STAGE/${runnerName}.token"
                    '')
                    runnerConfig.runners
                )}

                TMP_IMG="$OUT_IMG.tmp"
                rm -f "$TMP_IMG"
                mke2fs -t ext4 -d "$STAGE" -L ci-secrets -m 0 "$TMP_IMG" 16M >/dev/null
                chown microvm:kvm "$TMP_IMG"
                chmod 0400 "$TMP_IMG"
                mv "$TMP_IMG" "$OUT_IMG"
            '';
        };
    in {
        key = "shellix.nixos.forgejoRunner";

        imports = [
            flakeConfig.flake.modules.nixos.microvmHost
        ];

        options.shellix.forgejoRunner = {
            backend = lib.mkOption {
                type = lib.types.enum [
                    "microvm"
                    "host"
                ];
                default = "microvm";
                description = "Execution backend for Forgejo runners (microvm or host).";
            };

            microvm = {
                mem = lib.mkOption {
                    type = lib.types.ints.positive;
                    default = 1024;
                    description = "Memory size in MiB for the ci-runner Firecracker MicroVM.";
                };

                vcpu = lib.mkOption {
                    type = lib.types.ints.positive;
                    default = 1;
                    description = "Number of vCPUs for the ci-runner Firecracker MicroVM.";
                };

                ip = lib.mkOption {
                    type = lib.types.str;
                    default = "10.95.1.10/16";
                    description = "Static IPv4 CIDR assigned to the ci-runner MicroVM.";
                };

                mac = lib.mkOption {
                    type = lib.types.str;
                    default = "02:fc:00:01:00:01";
                    description = "MAC address assigned to the ci-runner MicroVM TAP interface.";
                };

                tapName = lib.mkOption {
                    type = lib.types.str;
                    default = "vm-ci";
                    description = "Host TAP interface name for the ci-runner MicroVM.";
                };

                workspaceSize = lib.mkOption {
                    type = lib.types.ints.positive;
                    default = 30720;
                    description = "Sparse persistent workspace volume size in MiB for /var/lib/forgejo-runner inside the CI MicroVM.";
                };

                storeOverlaySize = lib.mkOption {
                    type = lib.types.ints.positive;
                    default = 16480;
                    description = "Sparse writable /nix/store overlay volume size in MiB for /nix/.rw-store inside the CI MicroVM.";
                };

                cleanup = {
                    schedule = lib.mkOption {
                        type = lib.types.str;
                        default = "daily";
                        example = "*-*-* 04:00:00";
                        description = "systemd OnCalendar expression for in-guest cleanup of old Nix store paths and stale runner data.";
                    };

                    retentionDays = lib.mkOption {
                        type = lib.types.ints.positive;
                        default = 7;
                        description = "Retention period in days for unreferenced store paths and runner cache directories.";
                    };
                };

                extraPackages = lib.mkOption {
                    type = lib.types.listOf lib.types.package;
                    default = [];
                    description = "Additional packages installed inside the ci-runner Firecracker MicroVM.";
                };
            };

            runners = lib.mkOption {
                type = lib.types.attrsOf (
                    lib.types.submodule {
                        options = {
                            url = lib.mkOption {
                                type = lib.types.str;
                                example = "https://git.example.com";
                                description = "Forgejo instance URL.";
                            };

                            uuid = lib.mkOption {
                                type = lib.types.str;
                                example = "xxx-xxx-xxx-xxx-xxx";
                                description = "Runner UUID.";
                            };

                            tokenFile = lib.mkOption {
                                type = lib.types.pathWith {
                                    inStore = false;
                                    absolute = true;
                                };
                                example = "/run/secrets/forgejo-runner-token";
                                description = "Absolute host filesystem path outside the Nix store to the runner token file.";
                            };

                            labels = lib.mkOption {
                                type = lib.types.listOf lib.types.str;
                                default = ["nixos:host"];
                                defaultText = lib.literalExpression ''["nixos:host"]'';
                                example = ["nixos:host"];
                                description = "Runner labels executed in isolated host mode inside the MicroVM.";
                            };
                        };
                    }
                );
                default = {};
                description = "Attribute set of Forgejo runners to run as systemd services.";
            };
        };

        config = lib.mkMerge [
            (lib.mkIf (runnerConfig.backend == "host") {
                environment.systemPackages = [pkgs.forgejo-runner];
                systemd.services = mkRunnerServices (_: runner: runner.tokenFile);
            })
            (lib.mkIf (runnerConfig.backend == "microvm") {
                shellix.microvm.vms.ci-runner = {
                    inherit
                        (runnerConfig.microvm)
                        vcpu
                        mem
                        ip
                        mac
                        tapName
                        ;
                    autostart = true;
                    # Root is tmpfs so /nix/var/nix/db resets on every boot; recreating the
                    # overlay image avoids unregistered stale store paths after a VM restart.
                    preStart = ''
                        ${lib.getExe' pkgs.coreutils "rm"} -f ci-nix-store.ext4
                    '';
                    volumes = [
                        {
                            image = "ci-nix-store.ext4";
                            label = "nix-rw-store";
                            mountPoint = "/nix/.rw-store";
                            size = runnerConfig.microvm.storeOverlaySize;
                            autoCreate = true;
                        }
                        {
                            image = "ci-workspace.ext4";
                            mountPoint = "/var/lib/forgejo-runner";
                            size = runnerConfig.microvm.workspaceSize;
                            autoCreate = true;
                        }
                        {
                            image = "ci-secrets.ext4";
                            mountPoint = "/run/vm-secrets";
                            size = 16;
                            autoCreate = false;
                            readOnly = true;
                        }
                    ];
                    extraConfig = {
                        microvm.writableStoreOverlay = "/nix/.rw-store";

                        # microvm.nix forwards volume.readOnly to Firecracker but not guest fileSystems;
                        # mount read-only without journal replay or fsck so systemd does not fail on boot.
                        fileSystems."/run/vm-secrets" = {
                            options = [
                                "ro"
                                "noload"
                                "nosuid"
                                "nodev"
                                "noexec"
                            ];
                            noCheck = true;
                        };

                        nix = {
                            enable = true;
                            settings = {
                                experimental-features = [
                                    "nix-command"
                                    "flakes"
                                ];
                                allowed-users = ["*"];
                            };
                        };

                        programs.nix-ld.enable = true;

                        systemd = {
                            services =
                                mkRunnerServices (name: _: "/run/vm-secrets/${name}.token")
                                // {
                                    forgejo-runner-cleanup = {
                                        description = "Clean old Nix store paths and stale Forgejo runner data";
                                        environment.NIX_REMOTE = "daemon";
                                        serviceConfig = {
                                            Type = "oneshot";
                                            ExecStart = lib.getExe guestCleanupScript;
                                        };
                                    };
                                };
                            timers.forgejo-runner-cleanup = {
                                wantedBy = ["timers.target"];
                                timerConfig = {
                                    OnCalendar = runnerConfig.microvm.cleanup.schedule;
                                    Persistent = true;
                                    RandomizedDelaySec = "30m";
                                };
                            };
                        };

                        environment.systemPackages =
                            [pkgs.forgejo-runner]
                            ++ runnerConfig.microvm.extraPackages;
                    };
                };

                systemd.services."microvm@ci-runner".serviceConfig.ExecStartPre = [
                    "+${lib.getExe secretsPackScript}"
                ];
            })
        ];
    };
}
