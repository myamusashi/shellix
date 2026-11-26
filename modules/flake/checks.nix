{self, ...}: {
    perSystem = {
        lib,
        pkgs,
        system,
        ...
    }: {
        checks =
            {
                statix =
                    pkgs.runCommand "check-statix" {
                        nativeBuildInputs = [pkgs.statix];
                    } ''
                        statix check ${self}
                        touch $out
                    '';

                deadnix =
                    pkgs.runCommand "check-deadnix" {
                        nativeBuildInputs = [pkgs.deadnix];
                    } ''
                        deadnix --fail ${self}
                        touch $out
                    '';
            }
            // lib.optionalAttrs (system == "x86_64-linux") {
                myamusashi-toplevel = self.nixosConfigurations.myamusashi.config.system.build.toplevel;
                waltz-toplevel = self.nixosConfigurations.waltz.config.system.build.toplevel;
            };
    };
}
