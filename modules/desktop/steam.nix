{
    flake.modules.nixos.steam = {
        lib,
        pkgs,
        ...
    }: {
        programs.steam = {
            enable = lib.mkDefault true;
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
