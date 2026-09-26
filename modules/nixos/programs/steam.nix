{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.steam;
in {
    config = lib.mkIf cfg.enable {
        programs.steam = {
            enable = pkgs.lib.mkDefault true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
            gamescopeSession.enable = true;
            extraCompatPackages = [pkgs.proton-ge-bin];
        };
        programs.gamescope = {
            enable = true;
            enableWsi = true;
        };
    };
}
