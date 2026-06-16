{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.virt-manager;
in {
    config = lib.mkIf cfg.enable {
        programs.virt-manager = {
            enable = pkgs.lib.mkDefault true;
            package = pkgs.virt-manager;
        };
    };
}
