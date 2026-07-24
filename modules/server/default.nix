{lib, ...}: {
    imports = [
        ./database.nix
        ./forgejo.nix
        ./wireguard.nix
        ./nextcloud.nix
        ./nix-serve.nix
        ./monitoring.nix
        ./phpmyadmin.nix
        ./vaultwarden.nix
        ./vsftpd.nix
        ./php-app.nix
        ./cloudflared.nix
        ./mail.nix
        ./9router.nix
        ./headroom.nix
    ];

    options.shellix.server = {
        database.enable = lib.mkEnableOption "Enable database services";
        forgejo.enable = lib.mkEnableOption "Enable forgejo git services";
        monitoring.enable = lib.mkEnableOption "Enable monitoring using grafana and prometheus";
        wireguard.enable = lib.mkEnableOption "Enable WireGuard fast, modern, secure VPN tunnel";
        phpmyadmin.enable = lib.mkEnableOption "Enable database management using phpmyadmin";
        vaultwarden.enable = lib.mkEnableOption "Enable vaultwarden for password management";
        vsftpd.enable = lib.mkEnableOption "Enable vsftpd for transfer file (ssh)";
        nextcloud.enable = lib.mkEnableOption "Enable nextcloud for cloud services";
        nix-serve.enable = lib.mkEnableOption "Enable nix-serve for serving nix objects";
        mail.enable = lib.mkEnableOption "Enable stalwart mail server";
        cloudflared.enable = lib.mkEnableOption "Enable Cloudflare Tunnel";
        "9router".enable = lib.mkEnableOption "Enable 9Router AI LLM proxy router";
        headroom.enable = lib.mkEnableOption "Enable headroom-ai context compression proxy";
    };
}
