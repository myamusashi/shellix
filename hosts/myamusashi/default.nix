{...}: {
    imports = [
        ./configuration.nix
        ./env.nix
        ./networking.nix
        ./nixconfig.nix
        ./shellix.nix
        ./users.nix
        ./hardware/default.nix
        ./zen-browser.nix
    ];
}
