{
    perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
            buildInputs = [
                pkgs.alejandra
                pkgs.deadnix
                pkgs.nil
                pkgs.nixd
                pkgs.statix
            ];
            shellHook = ''
                echo "NixOS configuration development environment"
            '';
        };
    };
}
