{
    imports = [
        ../../modules/nixos/programs/default.nix
        ../../modules/nixos/services/default.nix
        ../../modules/server/default.nix
    ];

    shellix = {
        server."9router".enable = false;

        services = {
            audio.enable = true;
            backup.myamusashi.enable = true;
            oom.enable = true;
            plasma.enable = false;
            resolver.enable = true;
            scx.enable = true;
            display-manager = {
                sddm = {
                    enable = false;
                    wayland = {
                        enable = true;
                        compositor = "weston";
                    };
                    auto-login = {
                        enable = false;
                        user = "myamusashi";
                        session = "hyprland.desktop";
                    };
                };
            };

            clipse.enable = false;
            easyeffects = {
                enable = true;
                preset = "gentle-dynamics";
            };
            kbuildsycoca6.enable = false;
            hypridle.enable = false;
            kdeconnect.enable = true;
            mpd.enable = false;
            systemd.nm-applet.enable = false;
        };

        programs = {
            nushell = {
                enable = true;
                username = "myamusashi";
                setAsDefaultShell = true;
            };
            fish = {
                enable = true;
                username = "myamusashi";
                setAsDefaultShell = false;
            };
            steam.enable = true;
            virt-manager.enable = false;
            wireshark.enable = false;
            foot.enable = true;
            btop.enable = true;
            htop.enable = true;
            eza.enable = true;
            zoxide.enable = true;
            starship.enable = true;
            kitty.enable = true;
            lazygit.enable = true;
            mpv.enable = true;
            neovide.enable = false;
            neovim = {
                enable = true;

                languages = {
                    web = false;
                    python = false;
                    docker = false;
                    dart = false;
                    sql = false;
                    lint = false;
                };
            };
            shell.enable = false;
            spicetify.enable = false;
            vscode.enable = false;
            color-templates.enable = true;
            yazi.enable = true;
        };
    };
}
