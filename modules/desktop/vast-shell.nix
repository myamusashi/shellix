{inputs, ...}: {
    flake.modules.nixos.vastShell = {pkgs, ...}: {
        key = "shellix.nixos.vastShell";

        imports = [
            inputs.shell.nixosModules.default
        ];

        programs.quickshell-shell = {
            enable = true;
            installFonts = true;
            greetd = {
                enable = true;
                user = "myamusashi";
            };
        };

        environment.systemPackages = [
            pkgs.greetd
            inputs.shell.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        security.pam.services.greetd.text = ''
            auth      substack      login
            account   include       login
            password  substack      login
            session   include       login
        '';
    };
}
