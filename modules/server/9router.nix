{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.server."9router";
    port = toString config.shellix.variables.port.NINEROUTER;
    baseUrl = "http://localhost:${port}";
    stateDir = "/var/lib/9router";
    appDir = "${stateDir}/app";
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

            path = with pkgs; [
                nodejs
                git
                bash
            ];

            environment = {
                PORT = port;
                HOSTNAME = "0.0.0.0";
                NODE_ENV = "production";
            };

            preStart = ''
                if [ ! -f "${stateDir}/.built" ]; then
                    cd ${stateDir}
                    rm -rf app
                    git clone --depth 1 https://github.com/decolua/9router app
                    cd ${appDir}
                    cp .env.example .env
                    sed -i "s#NEXT_PUBLIC_BASE_URL=.*#NEXT_PUBLIC_BASE_URL=${baseUrl}#" .env
                    ${pkgs.nodejs}/bin/npm install
                    ${pkgs.nodejs}/bin/npm run build
                    touch ${stateDir}/.built
                fi
            '';

            script = ''
                cd ${appDir}
                ${pkgs.nodejs}/bin/npm run start
            '';

            serviceConfig = {
                Type = "simple";
                Restart = "always";
                RestartSec = 10;
                User = "9router";
                Group = "9router";
                WorkingDirectory = appDir;
                StateDirectory = "9router";
                AmbientCapabilities = "";
                CapabilityBoundingSet = "";
                NoNewPrivileges = true;
                PrivateTmp = true;
                ProtectSystem = "strict";
                ProtectHome = true;
                ReadWritePaths = stateDir;
            };
        };
    };
}
