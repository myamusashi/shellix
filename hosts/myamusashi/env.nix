{
    pkgs,
    inputs,
    ...
}: let
    electron-flags = [
        "--enable-features=Vulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,VaapiVideoEncoder,AcceleratedVideoEncoder,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,UseMultiPlaneFormatForHardwareVideo"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
        "--ozone-platform=wayland"
    ];

    wrapElectron = pkg: binary:
        pkgs.symlinkJoin {
            name = "${pkg.pname or pkg.name}-wrapped";
            paths = [
                (pkgs.writeShellScriptBin binary ''
                    export FONTCONFIG_FILE="${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
                    export FONTCONFIG_PATH="${pkgs.fontconfig.out}/etc/fonts"
                    exec ${pkg}/bin/${binary} ${builtins.concatStringsSep " " electron-flags} "$@"
                '')
                pkg
            ];
        };
in {
    environment = {
        systemPackages = with pkgs; [
            darkly
            greetd

            ## QoL for terminal
            bat
            duf
            pv
            mprisence
            libsixel
            ueberzugpp
            fd
            zellij
            ripgrep
            rich-cli
            mediainfo
            ouch
            glow
            hexyl
            antiprism
            fzf
            jq
            codegraph
            firecrawl-mcp
            fastfetch

            ## Archive and extraction
            unzip
            zip
            unrar
            p7zip

            ## Qt packages
            inputs.shell.packages.${stdenv.hostPlatform.system}.default
            lxqt.pcmanfm-qt
            lxqt.pavucontrol-qt
            lxqt.lxqt-archiver
            pinentry-qt
            media-downloader
            qtcreator
            inputs.myamusashi-pkgs.packages.${stdenv.hostPlatform.system}.telegram

            ## Android tools
            better-adb-sync
            scrcpy
            android-tools

            ## Networking
            iptables
            inetutils

            ## Music apps
            strawberry
            (pkgs.callPackage ../../modules/nixos/packages/custom/spotiFLAC.nix {})

            ## Wayland
            wl-clipboard
            hyprpicker
            hyprsunset

            ## video and document tools
            ffmpeg
            imagemagick
            ffmpegthumbnailer
            poppler-utils
            mpv
            lxqt.lximage-qt
            zathura

            ## Themes
            gtk3
            gtk4
            morewaita-icon-theme
            qt6Packages.qt6ct
            (callPackage ../../modules/nixos/packages/custom/future-cursor.nix {})
            (callPackage ../../modules/nixos/packages/custom/future-cyan-hyprcursor.nix {})

            ## screen recorder
            inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.wl-screenrec-fork

            ## Password managers
            pass-wayland
            wine-wayland
            winetricks
            wineWow64Packages.waylandFull
            protonup-qt

            ## gayming
            steam
            gamemode
            pcsx2

            ## Office
            unoconv

            ## Apps
            inputs.myamusashi-pkgs.packages.${stdenv.hostPlatform.system}.serein
            (wrapElectron vesktop "vesktop")
            inputs.myamusashi-pkgs.packages.${stdenv.hostPlatform.system}.zapfast
            inputs.myamusashi-pkgs.packages.${stdenv.hostPlatform.system}.qmlformat-rs
            inputs.myamusashi-pkgs.packages.${stdenv.hostPlatform.system}.mangaDesk
            (wrapElectron inputs.helium.packages.${stdenv.hostPlatform.system}.default "helium")

            ## Misc
            inputs.myamusashi-pkgs.packages.${stdenv.hostPlatform.system}.omp
            git-credential-manager
            gh
            git
            curl
            kdiff3
            (callPackage ../../modules/nixos/packages/custom/app2unit.nix {})
            sops
            gvfs
            wget2
            vim

            # remote desktop
            virt-viewer
            freerdp
            remmina

            (wrapElectron onlyoffice-desktopeditors "onlyoffice-desktopeditors")
            qbittorrent-enhanced-nox
            patchelf

            ## Hyprland plugins
            (inputs.hypr-scroll-overview.packages.${stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
                patches = [
                    ./overview.patch
                ];
            }))
            inputs.hypr-dynamic-cursors.packages.${stdenv.hostPlatform.system}.hypr-dynamic-cursors

            ## Nix tools
            nil
            alejandra
            statix

            ## LLM Model runtime
            ollama-vulkan

            ## Graphics
            libva
        ];

        sessionVariables = {
            # Theming (GTK removed)
            HYPRCURSOR_THEME = "Future-Cyan-Hyprcursor_Theme";
            HYPRCURSOR_SIZE = "50";
            QS_ICON_THEME = "MoreWaita";
            QT_QPA_PLATFORMTHEME = "qtengine";
            XCURSOR_THEME = "Future-cursors";
            XCURSOR_SIZE = "35";

            # Qt env
            QT_MEDIA_BACKEND = "ffmpeg";
            QT_FFMPEG_DECODING_HW_DEVICE_TYPES = "vaapi";

            # Wayland and Graphics
            QT_QPA_PLATFORM = "wayland";
            SDL_VIDEODRIVER = "wayland";
            CLUTTER_BACKEND = "wayland";
            LIBVA_DRIVER_NAME = "iHD";
            OZONE_PLATFORM = "wayland";
            WLR_NO_HARDWARE_CURSORS = 0;
            ELECTRON_OZONE_PLATFORM_HINT = "wayland";
            ANV_VIDEO_DECODE = 1;
            VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
            LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";

            # Multi-GPU support (Lmao i don't even have Multi-GPU)
            AQ_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
            AQ_WLR_DEVICES = "/dev/dri/card1:/dev/dri/card0";
            AQ_MGPU_NO_EXPLICIT = 0;

            # XDG
            XDG_CONFIG_HOME = "/home/$USER/.config";
            XDG_MENU_PREFIX = "plasma-";

            # Application specific settings
            FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=O";
            MOZ_DISABLE_RDD_SANDBOX = 1;
            MOZ_X11_EGL = "1";
            MOZ_ENABLE_WAYLAND = "1";
            MOZ_DRM_DEVICE = "/dev/dri/card1";
            _JAVA_AWT_WM_NONREPARENTING = 1;
            QT_WAYLAND_DISABLE_WINDOWDECORATION = 0;
            QT_AUTO_SCREEN_SCALE_FACTOR = 1;
            QT_ENABLE_HIGHDPI_SCALING = 1;
            QT_WAYLAND_FORCE_DPI = "physical";

            NIXOS_OZONE_WL = 1;
        };
    };

    xdg.mime = {
        enable = true;
        defaultApplications = {
            "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
            "text/plain" = "vim.desktop";
            "inode/directory" = "pcmanfm-qt.desktop";
            "application/x-gnome-saved-search" = "org.kde.dolphin.desktop";
            "application/pdf" = "zen-twilight.desktop";
            "image/png" = "lximage-qt.desktop.in";
            "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
            "image/jpeg" = "lximage-qt.desktop.in";
        };

        addedAssociations = {
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["draw.desktop"];
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["impress.desktop"];
            "image/png" = [
                "lximage-qt.desktop.in"
                "yazi.desktop"
            ];
            "text/x-log" = ["vim.desktop"];
            "image/svg+xml" = ["lximage-qt.desktop.in"];
            "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
            "text/x-java-source" = ["vim.desktop"];
            "image/jpeg" = ["lximage-qt.desktop.in"];
            "text/plain" = ["vim.desktop"];
            "text/x-shellscript" = ["vim.desktop"];
        };
    };
}
