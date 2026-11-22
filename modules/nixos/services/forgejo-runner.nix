{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.services.forgejo-runner;
    yamlFormat = pkgs.formats.yaml {};

    mkRunnerConfig = tokenPath: runner:
        yamlFormat.generate "forgejo-runner.yaml" {
            runner = {
                file = ".runner";
                capacity = 1;
                timeout = "3h";
                shutdown_timeout = "3h";
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
            container = {
                network = "";
                enable_ipv6 = false;
                privileged = false;
                workdir_parent = "/workspace";
                valid_volumes = [];
                docker_host = "";
                force_pull = false;
                force_rebuild = false;
            };
            host.workdir_parent = "";
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
                        NIX_REMOTE = "daemon";
                    };

                    path = with pkgs; [
                        bash
                        coreutils
                        curl
                        findutils
                        gawk
                        git
                        gnugrep
                        gnused
                        gnutar
                        gzip
                        jq
                        nix
                        nodejs
                        openssh
                        unzip
                    ];

                    serviceConfig = {
                        Type = "simple";
                        WorkingDirectory = "/var/lib/forgejo-runner/${name}";
                        StateDirectory = "forgejo-runner/${name}";
                        ExecStart = "${lib.getExe pkgs.forgejo-runner} daemon --config ${mkRunnerConfig (tokenPathFor name runner) runner}";
                        Restart = "on-failure";
                        RestartSec = 5;
                    };
                }
        )
        cfg.runners;

    secretsPackScript = pkgs.writeShellApplication {
        name = "forgejo-runner-pack-secrets";
        runtimeInputs = with pkgs; [
            coreutils
            e2fsprogs
            util-linux
        ];
        text = ''
            set -euo pipefail
            STATE_DIR="/var/lib/microvms/ci-runner"
            OUT_IMG="$STATE_DIR/ci-secrets.ext4"
            STAGE="$(mktemp -d /tmp/ci-secrets-stage.XXXXXX)"
            trap 'rm -rf "$STAGE"' EXIT

            mkdir -p "$STATE_DIR"
            ${lib.concatStringsSep "\n" (
                lib.mapAttrsToList (name: runner: ''
                    install -m 0400 "${runner.tokenFile}" "$STAGE/${name}.token"
                '')
                cfg.runners
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
    options.shellix.services.forgejo-runner = {
        backend = lib.mkOption {
            type = lib.types.enum [
                "microvm"
                "host"
            ];
            default = "microvm";
            description = ''
                Execution backend for Forgejo runners.
                - "microvm": Runs all runners inside an isolated Firecracker MicroVM in :host mode (no Podman/Docker required).
                - "host": Runs runners directly on the host without VM isolation.
            '';
        };

        microvm = {
            mem = lib.mkOption {
                type = lib.types.ints.positive;
                default = 4096;
                description = "Memory size in MiB for the ci-runner Firecracker MicroVM. The guest root filesystem is a tmpfs (capped at 50% of RAM by microvm.nix), so writes to / (such as /tmp and /nix/var) count against this RAM allocation.";
            };

            vcpu = lib.mkOption {
                type = lib.types.ints.positive;
                default = 2;
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
                default = 20480;
                description = "Sparse writable /nix/store overlay volume size in MiB for /nix/.rw-store inside the CI MicroVM.";
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
                            description = "Forgejo instance URL";
                        };

                        uuid = lib.mkOption {
                            type = lib.types.str;
                            example = "xxx-xxx-xxx-xxx-xxx";
                            description = "Runner UUID";
                        };

                        tokenFile = lib.mkOption {
                            type = lib.types.path;
                            example = "/path/to/token-file";
                            description = "Path to the file containing the runner registration token";
                        };

                        labels = lib.mkOption {
                            type = lib.types.listOf lib.types.str;
                            default = ["ubuntu-latest:host"];
                            defaultText = lib.literalExpression ''["ubuntu-latest:host"]'';
                            example = ["ubuntu-latest:host"];
                            description = "Runner labels executed in isolated host mode inside the MicroVM.";
                        };
                    };
                }
            );
            default = {};
            description = "Attrsets of Forgejo runners to run as systemd services";
        };
    };

    config = lib.mkIf cfg.enable (
        lib.mkMerge [
            (lib.mkIf (cfg.backend == "host") {
                environment.systemPackages = [pkgs.forgejo-runner];
                systemd.services = mkRunnerServices (_: runner: runner.tokenFile);
            })
            (lib.mkIf (cfg.backend == "microvm") {
                assertions = [
                    {
                        assertion = config.shellix.services.microvm.enable;
                        message = "shellix.services.forgejo-runner with backend = \"microvm\" requires shellix.services.microvm.enable = true.";
                    }
                ];

                shellix.services.microvm.vms.ci-runner = {
                    inherit
                        (cfg.microvm)
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
                            size = cfg.microvm.storeOverlaySize;
                            autoCreate = true;
                        }
                        {
                            image = "ci-workspace.ext4";
                            mountPoint = "/var/lib/forgejo-runner";
                            size = cfg.microvm.workspaceSize;
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

                        environment.systemPackages =
                            [pkgs.forgejo-runner]
                            ++ cfg.microvm.extraPackages;

                        systemd.services = mkRunnerServices (name: _: "/run/vm-secrets/${name}.token");
                    };
                };

                systemd.services."microvm@ci-runner".serviceConfig.ExecStartPre = [
                    "+${lib.getExe secretsPackScript}"
                ];
            })
        ]
    );
}
