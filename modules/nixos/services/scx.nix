{
    config,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.services.scx.enable {
        services.scx-loader = {
            enable = true;
            config.default_sched = "scx_bpfland";
        };
    };
}
