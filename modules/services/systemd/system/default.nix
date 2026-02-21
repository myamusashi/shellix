{lib, ...}: {
    imports = [
        ./cachix.nix
        ./stirling.nix
        ./cloudflare-tunnels.nix
    ];

    options.shellix.services.systemd.system = {
        cachix.enable = lib.mkEnableOption "Enable cachix daemon";
        stirling.enable = lib.mkEnableOption "Enable stirling-pdf for converting PDF";
        cloudflare-tunnels.enable = lib.mkEnableOption "Enable cloudflare-tunnels";
    };
}
