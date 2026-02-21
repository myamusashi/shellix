{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.nixos.fish;
in {
    config = lib.mkIf cfg.enable {
        programs.fish = {
            enable = lib.mkDefault true;

            shellAliases = {
                kiss = "${pkgs.kitty}/bin/kitty + kitten ssh";
                img = "${pkgs.libsixel}/bin/img2sixel";
                icat = "${pkgs.kitty}/bin/kitten icat";
                ls = "${pkgs.eza}/bin/eza --icons";
                lla = "${pkgs.eza}/bin/eza -a --icons";
            };

            shellInit = ''
                ${builtins.readFile ./shell.fish}

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
