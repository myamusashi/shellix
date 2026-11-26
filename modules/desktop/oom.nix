{
    flake.modules.nixos.desktopOom = {pkgs, ...}: {
        key = "shellix.nixos.desktopOom";

        # ananicy CachyOS rules prioritise interactive GUI apps, and systemd-oomd kills on swap pressure;
        # neither belongs on a low-RAM headless server.
        systemd.oomd = {
            enable = true;
            enableUserSlices = true;
        };

        services.ananicy = {
            enable = true;
            package = pkgs.ananicy-cpp;
            rulesProvider = pkgs.ananicy-rules-cachyos;
        };
    };
}
