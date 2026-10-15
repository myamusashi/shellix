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
                originRequest.noTLSVerify = true;
                default = "http_status:404";
                inherit (cfg) ingress;
            };
        };
    };
}
