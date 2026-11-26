{
    perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
                alejandra
                deadnix
                nil
                nixd
                statix
            ];
            shellHook = ''
                echo "NixOS configuration development environment"
            '';
        };
    };
}
