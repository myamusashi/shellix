{
    inputs,
    pkgs,
    ...
}: let
    electron-flags = [
        "--enable-features=Vulkan,VaapiVideoDecodeLinuxGL,VaapiIgnoreDriverChecks,VaapiVideoDecoder,VaapiVideoEncoder,AcceleratedVideoEncoder,UseMultiPlaneFormatForHardwareVideo,SkiaGraphite"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
    ];

    wrapElectron = pkg: binary:
        pkgs.symlinkJoin {
            name = "${pkg.pname or pkg.name}-wrapped";
            paths = [
                (pkgs.writeShellScriptBin binary ''
                    exec ${pkg}/bin/${binary} ${builtins.concatStringsSep " " electron-flags} "$@"
                '')
                pkg
            ];
        };

    helium-base = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
    helium = wrapElectron helium-base "helium";
in
    with pkgs; {
        system = [
            vim
            pciutils
            libgdiplus
            polkit
            vulkan-tools
            pinentry-qt
            udisks
            udiskie
            gparted
            libvirt
            upower
            upower-notify
            rich-cli
            bluez
            mediainfo
            ouch
            glow
            hexyl
            antiprism
            fzf
        ];

        nix-tools = {
            standard = [
                nixd
                alejandra
                statix
                nix-output-monitor
                nh
            ];

            full = [
                nixd
                nil
                alejandra
                statix
                nix-diff
                nix-tree
                nix-output-monitor
                nix-du
                vulnix
                deadnix
                nix-update
            ];
        };

        fonts = {
            nerd = with nerd-fonts; [
                hack-font
                jetbrains-mono
                inconsolata-lgc
            ];
            external = [
                (callPackage ./custom/feather-font.nix {})
                (callPackage ./custom/google-sans-flex.nix {})
                noto-fonts
            ];
        };

        network = [
            inetutils
            wireshark
            networkmanagerapplet
            cloudflared
        ];

        development = {
            code_editor = [zed-editor-fhs];
            containers = [podman-tui podman-compose podman];
            tools = [
                git
                gh
                curl
                kdiff3
                (callPackage ./custom/app2unit.nix {})
            ];
        };

        security = [pass-wayland bitwarden-cli (wrapElectron bitwarden-desktop "bitwarden")];

        multimedia = {
            office = [(wrapElectron onlyoffice-desktopeditors "onlyoffice-desktopeditors") libreoffice unoconv];
            apps = [
                telegram-desktop
                (wrapElectron vesktop "vesktop")
                helium
            ];
        };

        # Qt-based keystore
        kde = [kdePackages.kwallet kdePackages.kwalletmanager];

        gaming = {
            platform = [steam (wrapElectron heroic "heroic") gamemode];
            utilities = [
                wine-wayland
                winetricks
                wineWow64Packages.waylandFull
                protonup-qt
            ];
        };

        android = [adb-sync scrcpy android-tools];

        media = {
            editor = [ffmpeg-full imagemagick];
            viewer = [ffmpegthumbnailer poppler-utils mpv lxqt.lximage-qt zathura];
            screen_recorder = [grim slurp hyprshot wl-screenrec];
            misc = [playerctl cava mpg123];
        };

        wayland = {
            core = [wayland-protocols wl-clipboard];
            wallpaper = [swww waypaper hyprpaper];
            launcher = [rofi tofi wofi];
            hyprland = [
                hyprpicker
                hyprsunset
            ];
        };

        theming = with pkgs; {
            colors = [pywal16];
            apps = [pywalfox-native];
            tools = [kdePackages.qtstyleplugin-kvantum gtk3 gtk4];
            cursors = [
                (callPackage ./custom/future-cursor.nix {})
                (callPackage ./custom/future-cyan-hyprcursor.nix {})
            ];
            icons = [
                kanagawa-icon-theme
                vimix-icon-theme
                (callPackage ./custom/material-symbols.nix {})
                (callPackage ./custom/yet-another-monochrome-icon-set.nix {})
                morewaita-icon-theme
                (whitesur-icon-theme.override {themeVariants = ["default"];})
            ];
            qt = [whitesur-kde qt6Packages.qt6ct];
            gtk = [
                (whitesur-gtk-theme.override {
                    themeVariants = ["blue"];
                    colorVariants = ["dark"];
                    darkerColor = true;
                })
                (vimix-gtk-themes.override {
                    themeVariants = ["ruby"];
                    colorVariants = ["dark"];
                    sizeVariants = ["standard"];
                    tweaks = ["translucent"];
                })
            ];
        };
    }
