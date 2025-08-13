{
  /*
  ** We actually can use the default port from
  ** the OG modules through **config function**,
  ** but i want to change it for no reason
  */

  # OG port
  SSH_PORT = 22;
  HTTP_PORT = 80;
  HTTPS_PORT = 443;
  FTP_PORT = 21;

  # Custom port
  FORGEJO_PORT = 7597;
  GRAFANA_PORT = 7916;
  PROMETHEUS_PORT = 6764;
  PROMETHEUS-EXPORTERS_PORT = 6753;
  STIRLING-PDF_PORT = 1298;
  NEXTCLOUD_PORT = 4531;
  VAULTWARDEN_PORT = 8131;
  PHPMYADMIN_PORT = 7874;
  NIX-SERVE_PORT = 3731;

  # Identity
  SERVER = "waltz";
  ME = "myamusashi";
}
