{...}: {
    imports = [
        ./configuration.nix
        ./env.nix
        ./networking.nix
        ./nixconfig.nix
        ./shellix.nix
        ./users.nix
        ./hardware
        ./home-manager
    ];
}
