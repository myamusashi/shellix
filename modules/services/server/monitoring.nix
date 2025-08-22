{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.shellix.services.server.monitoring.enable {
    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = config.services.grafana.settings.server.http_port;
            domain = "dash.myamusashi.com";
            root_url = "http://dash.myamusashi.com";
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
                targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"];
              }
            ];
          }
        ];
      };

      prometheus.exporters.node = {
        enable = true;
        port = 9100;
        enabledCollectors = ["systemd"];
        extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi"];
      };

      nginx.virtualHosts."dash.myamusashi.com" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}
