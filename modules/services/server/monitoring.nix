{
    config,
    lib,
    ...
}: {
    imports = [
        ../../shared/Variable.nix
    ];
    config = lib.mkIf config.shellix.services.server.monitoring.enable {
        services = {
            grafana = {
                enable = true;
                settings = {
                    server = {
                        http_addr = "127.0.0.1";
                        http_port = config.shellix.variables.port.GRAFANA;
                        domain = "dash.myamusashi.com";
                    };
                    security.secret_key = config.sops.secrets.grafana_secret_key.path;
                };
            };

            prometheus = {
                enable = true;
                port = 9090;
                globalConfig.scrape_interval = "10s";
                scrapeConfigs = [
                    {
                        job_name = "node";
                        static_configs = [
                            {
                                targets = ["localhost:${toString config.shellix.variables.port.PROMETHEUS}"];
                            }
                        ];
                    }
                ];
            };

            prometheus.exporters.node = {
                enable = true;
                port = config.shellix.variables.port.PROMETHEUS-EXPORTERS;
                enabledCollectors = ["systemd"];
                extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi"];
            };

            nginx.virtualHosts."dash.myamusashi.com" = {
                locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString config.shellix.variables.port.GRAFANA}";
                    proxyWebsockets = true;
                    recommendedProxySettings = true;
                };
            };
        };
    };
}
