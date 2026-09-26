{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.services.forgejo-runner;
    mkRunnerService = name: runner: {
        "forgejo-runner-${name}" = {
            description = "Forgejo Runner — ${name}";
            after = ["network-online.target"];
            wants = ["network-online.target"];
            wantedBy = ["multi-user.target"];

            serviceConfig = {
                Type = "simple";
                ExecStart =
                    "${lib.getExe pkgs.forgejo-runner} daemon"
                    + " --url ${runner.url}"
                    + " --uuid ${runner.uuid}"
                    + " --token-url file://${runner.tokenFile}"
                    + " --label ${lib.concatStringsSep "," runner.labels}";
                Restart = "on-failure";
                RestartSec = 5;
            };
        };
    };
in {
    options.shellix.services.forgejo-runner.runners = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
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
                    default = ["ubuntu-latest:docker://catthehacker/ubuntu:act-latest"];
                    example = ["ubuntu-latest:docker://catthehacker/ubuntu:act-latest"];
                    description = "List of runner labels";
                };
            };
        });
        default = {};
        description = "Attrsets of Forgejo runners to run as systemd services";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.forgejo-runner];

        systemd.services = lib.mkMerge (lib.mapAttrsToList mkRunnerService cfg.runners);
    };
}
