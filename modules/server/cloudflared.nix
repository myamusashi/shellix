{
    flake.modules.nixos.cloudflared = {
        config,
        lib,
        ...
    }: let
        cloudflaredConfig = config.shellix.cloudflared;
        credentialsFile = config.sops.secrets.cloudflare_creds.path;
    in {
        key = "shellix.nixos.cloudflared";

        options.shellix.cloudflared.ingress = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
            description = "Ingress rules mapping hostname to target URL; entries from multiple aspects merge automatically.";
        };

        config.services.cloudflared = {
            enable = true;
            tunnels."home-server" = {
                inherit credentialsFile;
                originRequest.noTLSVerify = true;
                default = "http_status:404";
                inherit (cloudflaredConfig) ingress;
            };
        };
    };
}
