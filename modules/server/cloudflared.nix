{
    lib,
    config,
    ...
}: let
    cfg = config.shellix.server.cloudflared;
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
                credentialsFile = config.sops.secrets.cloudflare_creds.path;
                default = "http_status:404";
                inherit (cfg) ingress;
            };
        };
    };
}
