{
    lib,
    config,
    pkgs,
    inputs,
    ...
}: let
    cfg = config.shellix.programs.quickshell;
    quickshell-pkg = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [quickshell-pkg];
    };
}
