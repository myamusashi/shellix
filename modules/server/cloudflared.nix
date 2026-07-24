{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.server.cloudflared;
    domains = lib.attrNames cfg.ingress;
    credsFile = config.sops.secrets.cloudflare_creds.path;
in {
    options.shellix.server.cloudflared.ingress = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = ''
            Ingress rules as hostname → target URL.
            Other modules can add entries here and they will be merged.
        '';
    };

    config = lib.mkIf cfg.enable {
        services.cloudflared = {
            enable = true;
            tunnels."home-server" = {
                credentialsFile = credsFile;
                default = "http_status:404";
                inherit (cfg) ingress;
            };
        };

        systemd.services.cloudflared-route-dns = lib.mkIf (domains != []) {
            description = "Create Cloudflare Tunnel DNS records for ingress domains";
            after = ["network-online.target"];
            wants = ["network-online.target"];
            before = ["cloudflared-tunnel-home-server.service"];
            wantedBy = ["cloudflared-tunnel-home-server.service"];

            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
            };

            script = let
                cf = "${lib.getBin pkgs.cloudflared}/bin/cloudflared";
            in
                lib.concatStringsSep "\n" (map (
                    domain: "${cf} tunnel route dns home-server ${domain}"
                )
                domains);
        };
    };
}
