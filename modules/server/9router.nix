{
    lib,
    config,
    pkgs,
    inputs,
    ...
}: let
    cfg = config.shellix.server."9router";
    port = toString config.shellix.variables.port.NINEROUTER;
    stateDir = "/var/lib/9router";
    pkg = inputs.myamusashi-pkgs.packages.${pkgs.system}."9router";
in {
    config = lib.mkIf cfg.enable {
        users.users."9router" = {
            isSystemUser = true;
            group = "9router";
            description = "9Router AI LLM router service user";
            home = stateDir;
            createHome = true;
        };
        users.groups."9router" = {};

        systemd.services."9router" = {
            description = "9Router AI LLM Proxy Router";
            after = ["network-online.target"];
            wants = ["network-online.target"];
            wantedBy = ["multi-user.target"];

            environment = {
                PORT = port;
                HOSTNAME = "0.0.0.0";
                NODE_ENV = "production";
                NEXT_TELEMETRY_DISABLED = "1";
                DATA_DIR = "${stateDir}/data";
            };

            preStart = ''
                mkdir -p ${stateDir}/data
                chown -R 9router:9router ${stateDir}
            '';

            script = ''
                cd ${pkg}/lib/9router/app
                exec ${pkgs.nodejs}/bin/node custom-server.js
            '';

            serviceConfig = {
                Type = "simple";
                Restart = "always";
                RestartSec = 10;
                User = "9router";
                Group = "9router";
                WorkingDirectory = "${pkg}/lib/9router/app";
                StateDirectory = "9router";
                AmbientCapabilities = "";
                CapabilityBoundingSet = "";
                NoNewPrivileges = true;
                PrivateTmp = true;
                ProtectSystem = "full";
                ProtectHome = true;
                ReadWritePaths = stateDir;
            };
        };
    };
}
