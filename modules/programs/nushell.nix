flakeParts: let
    flakeConfig = flakeParts.config;
in {
    flake.modules.nixos.nushell = {
        config,
        lib,
        pkgs,
        ...
    }: let
        nushellConfig = config.shellix.nushell;

        environmentFile = pkgs.writeText "env.nu" (
            builtins.readFile ../../assets/shells/env.nu
            + (lib.optionalString (nushellConfig.username == "myamusashi") ''
                $env.GITHUB_TOKEN = (cat ${config.sops.secrets.github_token.path})
                $env.FIRECRAWL_API_KEY = (cat ${config.sops.secrets.firecrawl_api.path})
                $env.MINIMAX_API_KEY = (cat ${config.sops.secrets.commandcode_api.path})
                $env.config = {
                    show_banner: false
                }
            '')
        );

        configurationFile = pkgs.writeText "config.nu" (
            "source ${../../assets/shells/carapace.nu}\n" + builtins.readFile ../../assets/shells/config.nu
        );
    in {
        imports = [
            flakeConfig.flake.modules.nixos.zoxide
        ];
        options.shellix.nushell = {
            username = lib.mkOption {
                type = lib.types.str;
                example = "myamusashi";
                description = "User account configured for nushell.";
            };
            setAsDefaultShell = lib.mkEnableOption "Set nushell as the default user shell";
        };

        config = {
            environment = {
                shells = [pkgs.nushell];
                systemPackages = [
                    pkgs.nushell
                    pkgs.carapace
                    pkgs.nufmt
                ];
            };

            systemd.user.tmpfiles.rules = [
                "d %h/.config/nushell 0755 - - - -"
                "L+ %h/.config/nushell/env.nu - - - - ${environmentFile}"
                "L+ %h/.config/nushell/config.nu - - - - ${configurationFile}"
            ];

            users.users."${nushellConfig.username}".shell = lib.mkIf nushellConfig.setAsDefaultShell pkgs.nushell;
        };
    };
}
