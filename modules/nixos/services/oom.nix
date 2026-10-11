{
    config,
    lib,
    pkgs,
    ...
}: {
    # ananicy's CachyOS rules prioritise GUI apps, and oomd kills on swap pressure.
    # Neither belongs on a low-RAM headless server.
    config = lib.mkIf config.shellix.services.oom.enable {
        systemd.oomd = {
            enable = true;
            enableUserSlices = true;
        };

        # Auto-nice and auto-prioritize interactive desktop items
        services.ananicy = {
            enable = true;
            package = pkgs.ananicy-cpp;
            rulesProvider = pkgs.ananicy-rules-cachyos;
        };
    };
}
