{
    flake.modules.nixos.git = {
        key = "shellix.nixos.git";

        programs.git = {
            enable = true;
            config.credential.helper = "store";
        };
    };
}
