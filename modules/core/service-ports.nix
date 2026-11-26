{
    flake.modules.nixos.servicePorts = {lib, ...}: {
        key = "shellix.nixos.servicePorts";

        options.shellix.ports = {
            forgejo = lib.mkOption {
                type = lib.types.port;
                default = 7597;
                description = "Port number for Forgejo git service.";
            };
            ocis = lib.mkOption {
                type = lib.types.port;
                default = 9200;
                description = "Port number for ownCloud Infinite Scale (oCIS).";
            };
            vaultwarden = lib.mkOption {
                type = lib.types.port;
                default = 8131;
                description = "Port number for Vaultwarden password manager.";
            };
            pihole = lib.mkOption {
                type = lib.types.port;
                default = 8080;
                description = "Port number for Pi-hole web dashboard.";
            };
        };
    };
}
