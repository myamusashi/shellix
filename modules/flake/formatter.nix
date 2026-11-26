{inputs, ...}: {
    imports = [
        inputs.treefmt-nix.flakeModule
    ];

    perSystem = {pkgs, ...}: {
        treefmt = {
            projectRootFile = "flake.nix";
            programs = {
                alejandra = {
                    enable = true;
                    package = pkgs.alejandra;
                };
                deadnix.enable = true;
                statix.enable = true;
            };
            settings.formatter.alejandra.options = [
                "--experimental-config"
                ".alejandra.toml"
            ];
        };
    };
}
