{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.lazygit;
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.lazygit];
    };
}
