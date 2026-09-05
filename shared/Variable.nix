{lib, ...}: {
    /*
  ** We actually can use the default port from
  ** the OG modules through **config function**,
  ** but i want to change it for no reason
  */
    options.shellix.variables = {
        port = {
            SSH = lib.mkOption {
                type = lib.types.port;
                default = 22;
                description = "Port number for SSH";
            };
            HTTP = lib.mkOption {
                type = lib.types.port;
                default = 80;
                description = "Port number for HTTP";
            };
            HTTPS = lib.mkOption {
                type = lib.types.port;
                default = 443;
                description = "Port number for HTTPS";
            };
            FTP = lib.mkOption {
                type = lib.types.port;
                default = 21;
                description = "Port number for FTP";
            };
            FORGEJO = lib.mkOption {
                type = lib.types.port;
                default = 7597;
                description = "Port number for Forgejo git services";
            };
            GRAFANA = lib.mkOption {
                type = lib.types.port;
                default = 7916;
                description = "Port number for Grafana monitoring web";
            };
            PROMETHEUS = lib.mkOption {
                type = lib.types.port;
                default = 6764;
                description = "Port number for Prometheus data";
            };
            PROMETHEUS-EXPORTERS = lib.mkOption {
                type = lib.types.port;
                default = 6753;
                description = "Port number for Prometheus data exporter";
            };
            STIRLING-PDF = lib.mkOption {
                type = lib.types.port;
                default = 1298;
                description = "Port number for Stirling PDF manipulation";
            };
            OCIS = lib.mkOption {
                type = lib.types.port;
                default = 9200;
                description = "Port number for ownCloud Infinite Scale (oCIS)";
            };
            VAULTWARDEN = lib.mkOption {
                type = lib.types.port;
                default = 8131;
                description = "Port number for Vaultwarden self-hosted password manager";
            };
            PHPMYADMIN = lib.mkOption {
                type = lib.types.port;
                default = 7874;
                description = "Port number for phpmyadmin for manage database";
            };
            NIX-SERVE = lib.mkOption {
                type = lib.types.port;
                default = 3731;
                description = "Port number for nix-serve for serve binary cache nix";
            };
            NINEROUTER = lib.mkOption {
                type = lib.types.port;
                default = 20128;
                description = "Port number for 9Router AI LLM proxy router";
            };
            HEADROOM = lib.mkOption {
                type = lib.types.port;
                default = 8787;
                description = "Port number for headroom-ai context compression proxy";
            };
            PIHOLE = lib.mkOption {
                type = lib.types.port;
                default = 8080;
                description = "Port number for Pi-hole web dashboard";
            };
        };
    };
}
