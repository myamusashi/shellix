{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.server.headroom;
    port = toString config.shellix.variables.port.HEADROOM;
    stateDir = "/var/lib/headroom";
    python = pkgs.python313;
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

            path = with pkgs; [
                python
                python.pkgs.pip
                bash
            ];

            environment = {
                HOME = stateDir;
                PIP_NO_CACHE_DIR = "1";
            };

            preStart = ''
                if [ ! -d "${stateDir}/venv" ]; then
                    ${python}/bin/python -m venv ${stateDir}/venv
                fi
                ${stateDir}/venv/bin/pip install --quiet "headroom-ai[proxy]"
            '';

            script = ''
                ${stateDir}/venv/bin/headroom proxy --port ${port}
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
                ProtectSystem = "strict";
                ProtectHome = true;
                ReadWritePaths = stateDir;
            };
        };
    };
}
