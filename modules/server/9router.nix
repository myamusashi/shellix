{
    lib,
    config,
    pkgs,
    inputs,
    ...
}: let
    cfg = config.shellix.server."9router";
    port = toString config.shellix.variables.port.NINEROUTER;
    baseUrl = "http://localhost:${port}";
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

        environment.sessionVariables = {
            NEXT_PUBLIC_BASE_URL = baseUrl;
        };

        systemd.services."9router" = {
            description = "9Router AI LLM Proxy Router";
            after = ["network-online.target"];
            wants = ["network-online.target"];
            wantedBy = ["multi-user.target"];

            environment = {
                PORT = port;
                HOSTNAME = "0.0.0.0";
                NODE_ENV = "production";
                NEXT_PUBLIC_BASE_URL = baseUrl;
            };

            script = ''
                cd ${pkg}
                ${pkgs.nodejs}/bin/npm run start
            '';

            serviceConfig = {
                Type = "simple";
                Restart = "always";
                RestartSec = 10;
                User = "9router";
                Group = "9router";
                WorkingDirectory = stateDir;
                StateDirectory = "9router";
                AmbientCapabilities = "";
                CapabilityBoundingSet = "";
                NoNewPrivileges = true;
                PrivateTmp = true;
                ProtectSystem = "full";
                ReadWritePaths = stateDir;
            };
        };
    };
}
