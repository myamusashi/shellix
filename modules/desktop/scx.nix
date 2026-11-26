{
    flake.modules.nixos.scx = {
        key = "shellix.nixos.scx";

        services.scx-loader = {
            enable = true;
            config.default_sched = "scx_bpfland";
        };
    };
}
