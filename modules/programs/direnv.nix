{
    flake.modules.nixos.direnv = {
        key = "shellix.nixos.direnv";

        programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
        };
    };
}
