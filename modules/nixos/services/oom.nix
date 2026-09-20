{pkgs, ...}: {
    # proactive memory pressure management
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
}
