{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.fish;
in {
    config = lib.mkIf cfg.enable {
        users.users."${cfg.username}" = lib.mkIf cfg.setAsDefaultShell {
            shell = lib.mkDefault pkgs.fish;
        };
        programs.fish = {
            enable = lib.mkDefault true;

            shellAliases = {
                kiss = "${pkgs.kitty}/bin/kitty + kitten ssh";
                img = "${pkgs.libsixel}/bin/img2sixel";
                icat = "${pkgs.kitty}/bin/kitten icat";
                ls = "${pkgs.eza}/bin/eza --icons always";
                lla = "${pkgs.eza}/bin/eza -a --icons always";
            };

            shellInit = ''
                ${builtins.readFile ./config.fish}

                set -gx GITHUB_TOKEN (cat ${config.sops.secrets.github_token.path})

                function ws
                    ${pkgs.quickshell}/bin/qs -c lock ipc call img set "$argv[1]"
                end

                function fontlist
                    fc-list --format='%{family}\\n' | ${pkgs.ripgrep}/bin/rg "$argv[1]"
                end

            '';
        };
    };
}
