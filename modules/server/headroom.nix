{
    lib,
    config,
    pkgs,
    inputs,
    ...
}: let
    cfg = config.shellix.server.headroom;
    port = toString config.shellix.variables.port.HEADROOM;
    stateDir = "/var/lib/headroom";
    pkg = inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.headroom-ai;
in {
    config = lib.mkIf cfg.enable {
        users.users.headroom = {
            isSystemUser = true;
            group = "headroom";
            description = "Headroom AI context compression proxy service user";
            home = stateDir;
            createHome = true;
        };
        users.groups.headroom = {};

        systemd.services.headroom = {
            description = "Headroom AI Context Compression Proxy";
            after = ["network-online.target"];
            wants = ["network-online.target"];
            wantedBy = ["multi-user.target"];

            environment = {
                HOME = stateDir;
                HEADROOM_HOME = stateDir;
            };

            script = ''
                ${pkg}/bin/headroom proxy --port ${port} --host 0.0.0.0
            '';

            serviceConfig = {
                Type = "simple";
                Restart = "always";
                RestartSec = 10;
                User = "headroom";
                Group = "headroom";
                WorkingDirectory = stateDir;
                StateDirectory = "headroom";
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
