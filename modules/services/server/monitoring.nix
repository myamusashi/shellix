{
  config,
  lib,
  ...
}: let
  VARS = import ../../shared/Variable.nix;
in {
  config = lib.mkIf config.shellix.services.server.monitoring.enable {
    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = VARS.GRAFANA_PORT;
            domain = "dash.myamusashi.com";
          };
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
                targets = ["localhost:${toString VARS.PROMETHEUS_PORT}"];
              }
            ];
          }
        ];
      };

      prometheus.exporters.node = {
        enable = true;
        port = VARS.PROMETHEUS-EXPORTERS_PORT;
        enabledCollectors = ["systemd"];
        extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi"];
      };

      nginx.virtualHosts."dash.myamusashi.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString VARS.GRAFANA_PORT}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}
