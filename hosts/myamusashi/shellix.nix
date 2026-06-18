{
    imports = [
        ../../modules/nixos/programs/default.nix
        ../../modules/nixos/services/default.nix
        ../../modules/server/default.nix
    ];

    shellix = {
        server.phpmyadmin.enable = false;

        services = {
            audio.enable = true;
            backup.myamusashi.enable = true;
            earlyoom.enable = false;
            plasma.enable = true;
            resolver.enable = true;
            scx.enable = true;
            display-manager = {
                sddm = {
                    enable = true;
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
            hypridle.enable = true;
            kdeconnect.enable = true;
            mpd.enable = false;
            systemd.nm-applet.enable = true;
        };

        programs = {
            fish.enable = true;
            steam.enable = true;
            virt-manager.enable = false;
            wireshark.enable = true;
            btop.enable = true;
            fastfetch.enable = true;
            foot.enable = true;
            htop.enable = true;
            kitty.enable = true;
            lazygit.enable = true;
            mpv.enable = true;
            neovide.enable = false;
            neovim.enable = true;
            shell.enable = true;
            spicetify.enable = false;
            vscode.enable = true;
            matugen.enable = true;
            yazi.enable = true;
        };
    };
}
