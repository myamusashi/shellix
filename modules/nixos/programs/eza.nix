{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.eza;
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.eza];
    };
}
