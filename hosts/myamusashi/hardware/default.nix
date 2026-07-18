{...}: {
    imports = [
        "${fetchGit {
            url = "https://github.com/NixOS/nixos-hardware.git";
            rev = "2379bc40992ec29feb1933bb4acd224fa055f3f8";
        }}/lenovo/thinkpad/x270"
        ./bootConfig.nix
        ./hardware-configuration.nix
        ./services.nix
        ./virtualization.nix
        ./packages.nix
        ./graphics.nix
        ./hardware-features.nix
        ./security.nix
        ./zram.nix
    ];
}
