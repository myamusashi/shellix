{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.services.forgejo-runner;

    # act_runner copies the checkout into /var/run/act inside the job container.
    # Stock act-latest images ship /var/run as a symlink -> ../run, and Podman 5.x
    # (behind the dockerCompat socket) rejects CopyToContainer through it with
    # "path escapes from parent", nektos/act#6092, a Docker 29.5.0+ regression.
    actImageRef = "localhost/act-fixed:latest";
    actContainerfile = pkgs.writeText "act-fixed.Containerfile" ''
        FROM docker.io/catthehacker/ubuntu:act-latest
        RUN rm -f /var/run && mkdir -p /var/run
    '';
    # podman build needs a context directory; -f points at the Containerfile.
    actBuildContext = pkgs.runCommand "act-fixed-context" {} ''
        mkdir -p $out
        cp ${actContainerfile} $out/Containerfile
    '';

    # Must land in the store the runner actually uses. Runner units have no User=,
    # so they run as root and talk to /var/run/docker.sock (root's podman).
    actImageLoad = pkgs.writeShellScriptBin "forgejo-act-image-load" ''
        set -euo pipefail
        podman=${lib.getExe pkgs.podman}
        if $podman image exists ${actImageRef} 2>/dev/null; then
            echo "act job image already present: ${actImageRef}"
            exit 0
        fi
        $podman build --cgroup-manager=cgroupfs \
            -t ${actImageRef} \
            ${actBuildContext}
        $podman image exists ${actImageRef}
    '';
in {
    options.shellix.services.forgejo-runner.runners = lib.mkOption {
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
                        default = ["ubuntu-latest:docker://${actImageRef}"];
                        defaultText = lib.literalExpression ''["ubuntu-latest:docker://${actImageRef}"]'';
                        example = ["ubuntu-latest:docker://localhost/act-fixed:latest"];
                        description = ''
                            Runner labels. The default points at the locally built act job
                            image which works around nektos/act#6092; the runners only pick jobs
                            that request it.
                        '';
                    };

                    containerNetwork = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                        example = "podman";
                        description = ''
                            Docker/Podman network for job containers. Set to your compose network name
                            so job containers can resolve the Forgejo instance hostname.
                            If null, forgejo-runner creates an isolated network per job (default behavior).
                        '';
                    };
                };
            }
        );
        default = {};
        description = "Attrsets of Forgejo runners to run as systemd services";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.forgejo-runner];

        systemd.services = (
            lib.listToAttrs (
                [
                    {
                        name = "forgejo-runner-act-image";
                        value = {
                            description = "Forgejo Runner — build and load act job image";
                            after = ["network-online.target"];
                            wants = ["network-online.target"];
                            wantedBy = ["multi-user.target"];
                            before = lib.mapAttrsToList (name: _: "forgejo-runner-${name}.service") cfg.runners;
                            serviceConfig = {
                                Type = "oneshot";
                                RemainAfterExit = true;
                                ExecStart = lib.getExe actImageLoad;
                            };
                        };
                    }
                ]
                ++ (lib.mapAttrsToList (name: runner: {
                    name = "forgejo-runner-${name}";
                    value = {
                        description = "Forgejo Runner — ${name}";
                        after = [
                            "network-online.target"
                            "forgejo-runner-act-image.service"
                        ];
                        wants = [
                            "network-online.target"
                            "forgejo-runner-act-image.service"
                        ];
                        wantedBy = ["multi-user.target"];

                        serviceConfig = let
                            configFile = pkgs.writeText "forgejo-runner-${name}.yaml" ''
                                runner:
                                  file: ".runner"
                                  capacity: 1
                                  timeout: "3h"
                                  shutdown_timeout: "3h"
                                  insecure: false
                                  fetch_timeout: "30s"
                                  fetch_interval: "2s"
                                  report_interval: "1s"
                                  labels: ${lib.concatStringsSep "\n  - " (lib.map (l: "- ${l}") runner.labels)}
                                cache:
                                  enabled: true
                                  port: 0
                                  proxy_port: 0
                                container:
                                  network: ${
                                    if runner.containerNetwork == null
                                    then ""
                                    else "\"" + runner.containerNetwork + "\""
                                }
                                  enable_ipv6: false
                                  privileged: false
                                  workdir_parent: "/workspace"
                                  valid_volumes: []
                                  docker_host: "-"
                                  force_pull: false
                                  force_rebuild: false
                                host:
                                  workdir_parent: ""
                                server:
                                  connections:
                                    default:
                                      url: ${runner.url}
                                      uuid: ${runner.uuid}
                                      token_url: file://${runner.tokenFile}
                                      labels: ${lib.concatStringsSep "\n      - " (lib.map (l: "- ${l}") runner.labels)}
                            '';
                        in {
                            Type = "simple";
                            ExecStart = "${lib.getExe pkgs.forgejo-runner} daemon" + " --config ${configFile}";
                            Restart = "on-failure";
                            RestartSec = 5;
                        };
                    };
                })
                cfg.runners)
            )
        );
    };
}
