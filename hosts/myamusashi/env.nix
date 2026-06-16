{
    pkgs,
    inputs,
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
in {
    environment = {
        systemPackages = with pkgs; [
            # darkly <-- code editor qol here
            # stylua
            # flutter
            netbeans # <-- tell me when this fuckass semester ends so i can remove this fuckass apps

            ## QoL for terminal
            bat
            duf
            pv
            mprisence
            libsixel
            ueberzugpp
            fd
            zellij
            eza
            ripgrep
            rich-cli
            mediainfo
            ouch
            glow
            hexyl
            antiprism
            fzf
            jq
            # yt-dlp

            ## Archive and extraction
            unzip
            zip
            unrar
            p7zip

            ## Qt packages
            kdePackages.dolphin
            inputs.shell.packages.${pkgs.stdenv.hostPlatform.system}.default
            lxqt.pavucontrol-qt
            pinentry-qt
            media-downloader
            qtcreator
            telegram-desktop
            kdePackages.kwallet
            kdePackages.kwalletmanager
            # qt6.qt5compat
            # qt6.qtgraphs
            # kdePackages.qtcharts

            ## Android tools
            adb-sync
            scrcpy
            android-tools

            ## Networking
            iptables
            inetutils
            networkmanagerapplet
            bluez
            cloudflared
            # iw

            ## Music apps
            strawberry
            # (pkgs.callPackage ../../modules/packages/custom/spotiFLAC.nix {})
            # spotify

            ## Fonts
            maple-mono.NF
            noto-fonts
            weather-icons
            (import
            ../../modules/nixos/packages/custom/google-sans-flex.nix
            {inherit (pkgs) stdenv lib unzip;})

            ## Sharing file tools
            rclone
            rclone-browser

            ## Wayland
            wl-clipboard
            hyprpicker
            hyprsunset

            ## video and document tools
            ffmpeg-full
            imagemagick
            ffmpeg
            ffmpegthumbnailer
            poppler-utils
            mpv
            lxqt.lximage-qt
            zathura
            playerctl
            cava
            mpg123

            ## Themes
            kdePackages.qtstyleplugin-kvantum
            gtk3
            gtk4
            morewaita-icon-theme
            qt6Packages.qt6ct
            (import ../../modules/nixos/packages/custom/future-cursor.nix {inherit (pkgs) stdenvNoCC lib fetchFromGitHub;})
            (import ../../modules/nixos/packages/custom/future-cyan-hyprcursor.nix {inherit (pkgs) stdenvNoCC lib fetchFromGitLab;})

            ## screen recorder and screenshot tools
            grim
            slurp
            hyprshot
            wl-screenrec

            ## Password managers
            pass-wayland
            bitwarden-cli
            wine-wayland
            winetricks
            wineWow64Packages.waylandFull
            protonup-qt

            ## gayming
            steam
            (wrapElectron heroic "heroic")
            gamemode

            ## Office
            libreoffice
            unoconv

            ## Apps
            (wrapElectron vesktop "vesktop")
            (wrapElectron inputs.helium.packages.${stdenv.hostPlatform.system}.default "helium")

            ## Misc
            darkly
            git-credential-manager
            gh
            git
            curl
            kdiff3
            (import ../../modules/nixos/packages/custom/app2unit.nix {inherit (pkgs) lib stdenvNoCC fetchFromGitHub makeWrapper bash systemd coreutils findutils gnugrep git gnused scdoc gawk libnotify;})
            sops
            wl-screenrec
            gvfs
            wget2
            inputs.antigravity-flakes.packages.${stdenv.hostPlatform.system}.default
            vim
            polkit
            inputs.hypr-scroll-overview.packages.${stdenv.hostPlatform.system}.default
            inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default
            (wrapElectron onlyoffice-desktopeditors "onlyoffice-desktopeditors")
            qbittorrent-enhanced-nox
            patchelf

            ## Nix tools
            nil
            alejandra
            statix
            nh
        ];

        sessionVariables = {
            # Theming (GTK removed)
            HYPRCURSOR_THEME = "Future-Cyan-Hyprcursor_Theme";
            HYPRCURSOR_SIZE = "50";
            QS_ICON_THEME = "Papirus";
            QT_QPA_PLATFORMTHEME = "qtengine";
            XCURSOR_THEME = "Future-Cyan-Hyprcursor_Theme";
            XCURSOR_SIZE = "35";

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
            EDITOR = "nvim";
            MOZ_DISABLE_RDD_SANDBOX = 1;
            MOZ_X11_EGL = "1";
            MOZ_ENABLE_WAYLAND = "1";
            MOZ_DRM_DEVICE = "/dev/dri/card1";
            _JAVA_AWT_WM_NONREPARENTING = 1;
            QT_WAYLAND_DISABLE_WINDOWDECORATION = 0;
            QT_AUTO_SCREEN_SCALE_FACTOR = 1;
            QT_ENABLE_HIGHDPI_SCALING = 1;
            QT_WAYLAND_FORCE_DPI = "physical";
        };
    };

    xdg.mime = {
        enable = true;
        defaultApplications = {
            "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
            "text/plain" = "helium.desktop";
            "inode/directory" = "org.kde.dolphin.desktop";
            "application/x-gnome-saved-search" = "org.kde.dolphin.desktop";
            "image/png" = "lximage-qt.desktop.in";
            "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
            "image/jpeg" = "lximage-qt.desktop.in";
        };

        addedAssociations = {
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["draw.desktop"];
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["impress.desktop"];
            "image/png" = ["lximage-qt.desktop.in" "yazi.desktop"];
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
