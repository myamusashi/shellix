{
    config,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.services.nixos.scx.enable {
        services.scx = {
            enable = true;
            scheduler = "scx_rusty";
        };
    };
}
