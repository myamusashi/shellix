{
    pkgs,
    inputs,
    ...
}: {
    imports = [
        ../../modules/shared/Colors.nix
        ../../modules/packages/home-packages.nix
        ../../modules/programs/home-manager/default.nix
        ../../modules/services/systemd/user/default.nix
        ../../modules/services/home-manager/default.nix
    ];
    home = {
        username = "myamusashi";
        homeDirectory = "/home/myamusashi";
        stateVersion = "24.11";
    };

    programs = {
        home-manager.enable = true;
        direnv = {
            enable = true;
            nix-direnv.enable = true;
            config.global.hide_env_diff = true;
        };
    };

    shellix = {
        matugen.colors.enable = true;
        programs.home = {
            btop.enable = true;
            fastfetch.enable = true;
            foot.enable = true;
            htop.enable = true;
            hyprland = {
                enable = true;
                plugins = {
                    enable = true;
                    hypr-dynamic-cursors = {
                        enable = true;
                    };
                };
            };
            kitty.enable = true;
            lazygit.enable = true;
            mango.enable = true;
            shell.enable = true;
            yazi.enable = true;
            spicetify.enable = true;
            mpv.enable = true;
            neovim.enable = true;
            neovide.enable = true;
            vscode.enable = true;
            matugen.enable = true;
        };

        services = {
            home-manager = {
                clipse.enable = true;
                easyeffects.enable = true;
                hypridle.enable = true;
                kdeconnect.enable = true;
                mpd.enable = true;
            };
            systemd.user = {
                adzan.enable = false;
                nm-applet.enable = true;
                weather-widget.enable = false;
            };
        };

        packages.home = {
            enable = true;

            customPackages = with pkgs; [
                git-credential-manager
                libsixel
                ueberzugpp
                fd
                p7zip
                zellij
                jq
                eza
                gapless
                ripgrep
                iw
                qtcreator
                darkly
                imagemagick
                lucide
                libnotify
                inputs.antigravity-flakes.packages.${stdenv.hostPlatform.system}.default
                (la-capitaine-icon-theme.overrideAttrs {dontCheckForBrokenSymlinks = true;})
                python314Packages.mutagen
                qt6.qt5compat
                media-downloader
                yt-dlp
                qt6.qtgraphs
                kdePackages.qtcharts
                wl-gammactl
                brightnessctl
                weather-icons
                wlr-randr
                (callPackage ./extra/google-sans-flex.nix {})
            ];
            excludePackages = [
                "neovide"
                "rofi"
                "pinentry-curses"
                "comic-shanns-mono"
                "jetbrains-mono"
                "nix-du"
                "nix-diff"
                "vulnix"
                "deadnix"
                "nix-update"
                "onlyoffice-desktopeditors"
                "proton-qt"
                "kanagawa-icon-theme"
                "vimix-icon-theme"
                "morewaita-icon-theme"
                "whitesur-kde"
                "zed"
            ];

            fonts = {
                nerd = true;
                external = true;
            };

            nix-tools = {
                standard = true;
            };

            theming = {
                colors = true;
                apps = true;
                tools = true;
                cursors = true;
                icons = true;
                qt = true;

                defaultCursor = "Future-Cyan-Hyprcursor-theme";
                defaultCursorSize = 24;
            };

            development = {
                code_editor = true;
                containers = true;
            };

            multimedia = {
                office = true;
                apps = true;
            };

            gaming = {
                platform = true;
                utilities = true;
            };

            media = {
                editor = true;
                viewer = true;
                misc = true;
            };

            wayland = {
                core = true;
                hyprland = true;
            };
        };
    };

    programs.git = {
        enable = true;
        settings = {
            credential.helper = "store";

            user.name = "myamusashi";
            user.mail = "myamusashi@proton.me";
            alias = {
                ci = "commit";
                sw = "checkout";
                s = "status";
            };
        };
        lfs.enable = true;
    };

    qt = {
        enable = true;
        platformTheme.name = "qtct";
        style = {
            package = with pkgs; [
                darkly
            ];
        };
    };

    fonts.fontconfig = {
        enable = true;
        defaultFonts = {
            serif = ["Google Sans Flex"];
            monospace = ["Maple Mono NF"];
            sansSerif = ["Google Sans Flex"];
        };
    };

    xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
            xdg-desktop-portal
            kdePackages.xdg-desktop-portal-kde
            xdg-desktop-portal-hyprland
        ];
        config = {
            common.default = "hyprland;kde";
            pantheon.default = "kde";
        };
    };
}
