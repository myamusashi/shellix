{
    pkgs,
    inputs,
    ...
}: {
    imports = [
        inputs.zen-browser.homeModules.beta
        ../../modules/packages/home-packages.nix
        ../../modules/programs/home-manager/default.nix
        ../../modules/services/home-manager/default.nix
    ];
    home = {
        username = "myamusashi";
        homeDirectory = "/home/myamusashi";
        stateVersion = "24.11";
    };

    programs = {
        home-manager.enable = true;
        starship.enable = true;
        direnv = {
            enable = true;
            nix-direnv.enable = true;
            config.global.hide_env_diff = true;
        };
        zen-browser = {
            enable = true;
            setAsDefaultBrowser = true;
        };
    };

    shellix = {
        programs.home = {
            btop.enable = true;
            fastfetch.enable = true;
            foot.enable = true;
            htop.enable = true;
            kitty.enable = true;
            lazygit.enable = true;
            shell.enable = true;
            yazi.enable = true;
            spicetify.enable = false;
            mpv.enable = true;
            neovim.enable = true;
            neovide.enable = false;
            vscode.enable = false;
            matugen.enable = true;
            quickshell.enable = true;
        };

        services = {
            home-manager = {
                clipse.enable = false;
                easyeffects = {
                    enable = true;
                    preset = "gentle-dynamics"; # gentle-dynamics, earphone-wired
                };
                hypridle.enable = true;
                kdeconnect.enable = true;
                mpd.enable = true;
                systemd.nm-applet.enable = true;
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
                ripgrep
                iw
                qtcreator
                imagemagick
                lucide
                libnotify
                inputs.antigravity-flakes.packages.${stdenv.hostPlatform.system}.default
                qt6.qt5compat
                media-downloader
                yt-dlp
                qt6.qtgraphs
                kdePackages.qtcharts
                wl-gammactl
                weather-icons
                wlr-randr
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

    systemd.user.startServices = "sd-switch";

    wayland.windowManager.hyprland = {
        enable = true;
        package = pkgs.hyprland;
    };

    programs.git = {
        enable = true;
        settings = {
            credential.helper = "store";

            user.name = "myamusashi";
            user.mail = "myamusashi@users.noreply.github.com";
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
        platformTheme.name = "qtengine";
        style = {
            package = with pkgs; [
                darkly
            ];
        };
    };

    fonts.fontconfig = {
        enable = true;
        defaultFonts = {
            serif = ["Segoe UI"];
            monospace = ["Maple Mono NF"];
            sansSerif = ["Segoe UI"];
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
