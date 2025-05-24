{
  pkgs,
  config,
  ...
}: {
  # Konfigurasi systemd service
  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel Service";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = "cloudflared";
      Group = "cloudflared";
      Restart = "always";
      RestartSec = "5";

      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = ["/var/lib/cloudflared"];

      # Matikan namespace mounting
      PrivateNetwork = false;
      PrivateNamespaces = false;
      RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = ["@system-service"];

      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/cloudflared";
      ExecStart = "/bin/sh -c '${pkgs.cloudflared}/bin/cloudflared tunnel run --token $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.cloudflare_creds.path})'";
      LoadCredential = [
        "cloudflare_creds:${config.sops.secrets.cloudflare_creds.path}"
      ];
    };
  };
}
