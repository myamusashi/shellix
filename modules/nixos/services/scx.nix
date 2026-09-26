{
    config,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.services.scx.enable {
        services.scx = {
            enable = true;
            scheduler = "scx_bpfland";
        };
    };
}
