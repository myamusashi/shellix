{pkgs, ...}: {
  systemd.services.cloudflare_proxy-dns = {
    description = "Cloudflare Tunnel Service";
    after = [
      "network-online.target"
      "forgejo.service"
      "nextcloud-setup.service"
      "sshd.service"
      "stirling-pdf.service"
      "forgejo.service"
      "nix-serve.service"
    ];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Restart = "always";
      RestartSec = 15;

      ExecStart = "/bin/sh -c '${pkgs.cloudflared}/bin/cloudflared proxy-dns";
    };
  };
}
