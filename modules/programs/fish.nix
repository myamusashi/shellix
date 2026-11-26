{
    flake.modules.nixos.fish = {
        config,
        lib,
        pkgs,
        ...
    }: let
        fishConfig = config.shellix.fish;
    in {
        options.shellix.fish = {
            username = lib.mkOption {
                type = lib.types.str;
                example = "myamusashi";
                description = "User account configured for fish shell.";
            };
            setAsDefaultShell = lib.mkEnableOption "Set fish as the default user shell";
        };

        config = {
            users.users."${fishConfig.username}" = lib.mkIf fishConfig.setAsDefaultShell {
                shell = lib.mkDefault pkgs.fish;
            };

            programs.fish = {
                enable = lib.mkDefault true;

                shellAliases =
                    {
                        ls = "${pkgs.eza}/bin/eza --icons always";
                        lla = "${pkgs.eza}/bin/eza -a --icons always";
                    }
                    // lib.optionalAttrs (fishConfig.username == "myamusashi") {
                        kiss = "${pkgs.kitty}/bin/kitty + kitten ssh";
                        img = "${pkgs.libsixel}/bin/img2sixel";
                        icat = "${pkgs.kitty}/bin/kitten icat";
                    };

                shellInit = ''
                    ${builtins.readFile ../../assets/shells/config.fish}
                    ${lib.optionalString (fishConfig.username == "myamusashi") ''
                        set -gx GITHUB_TOKEN (cat ${config.sops.secrets.github_token.path})
                    ''}

                    function fontlist
                        fc-list --format='%{family}\\n' | ${pkgs.ripgrep}/bin/rg "$argv[1]"
                    end
                '';
            };
        };
    };
}
