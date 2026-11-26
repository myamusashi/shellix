{inputs, ...}: {
    flake.modules.nixos.myamusashiPackages = {pkgs, ...}: let
        system = pkgs.stdenv.hostPlatform.system;
        myamusashiPackages = inputs.myamusashi-pkgs.packages.${system};

        electronFlags = [
            "--enable-features=Vulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,VaapiVideoEncoder,AcceleratedVideoEncoder,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,UseMultiPlaneFormatForHardwareVideo"
            "--ignore-gpu-blocklist"
            "--enable-zero-copy"
            "--ozone-platform=wayland"
        ];

        wrapElectron = package: binaryName:
            pkgs.symlinkJoin {
                name = "${package.pname or package.name}-wrapped";
                paths = [
                    (pkgs.writeShellScriptBin binaryName ''
                        export FONTCONFIG_FILE="${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
                        export FONTCONFIG_PATH="${pkgs.fontconfig.out}/etc/fonts"
                        exec ${package}/bin/${binaryName} ${builtins.concatStringsSep " " electronFlags} "$@"
                    '')
                    package
                ];
            };
    in {
        key = "shellix.nixos.myamusashiPackages";

        environment = {
            systemPackages = [
                pkgs.darkly
                pkgs.bat
                pkgs.duf
                pkgs.pv
                pkgs.mprisence
                pkgs.libsixel
                pkgs.ueberzugpp
                pkgs.fd
                pkgs.zellij
                pkgs.ripgrep
                pkgs.rich-cli
                pkgs.mediainfo
                pkgs.ouch
                pkgs.glow
                pkgs.hexyl
                pkgs.antiprism
                pkgs.fzf
                pkgs.jq
                pkgs.firecrawl-mcp
                pkgs.fastfetch
                pkgs.unzip
                pkgs.zip
                pkgs.unrar
                pkgs.p7zip
                pkgs.qt6.qtsvg
                pkgs.lxqt.pcmanfm-qt
                pkgs.lxqt.pavucontrol-qt
                pkgs.lxqt.lxqt-archiver
                pkgs.pinentry-qt
                pkgs.media-downloader
                pkgs.qtcreator
                myamusashiPackages.telegram
                pkgs.better-adb-sync
                pkgs.scrcpy
                pkgs.android-tools
                pkgs.iptables
                pkgs.inetutils
                pkgs.strawberry
                (pkgs.callPackage ../../../packages/mornye.nix {})
                pkgs.samba
                pkgs.cifs-utils
                pkgs.ffmpeg
                pkgs.imagemagick
                pkgs.ffmpegthumbnailer
                pkgs.poppler-utils
                pkgs.lxqt.lximage-qt
                pkgs.zathura
                pkgs.gtk3
                pkgs.gtk4
                pkgs.morewaita-icon-theme
                pkgs.qt6Packages.qt6ct
                (pkgs.callPackage ../../../packages/future-cursor.nix {})
                (pkgs.callPackage ../../../packages/future-cyan-hyprcursor.nix {})
                myamusashiPackages.wl-screenrec-fork
                pkgs.pass-wayland
                pkgs.wine-wayland
                pkgs.winetricks
                pkgs.wineWow64Packages.waylandFull
                pkgs.protonup-qt
                pkgs.gamemode
                pkgs.pcsx2
                pkgs.unoconv
                myamusashiPackages.wordcraft
                myamusashiPackages.yapfast
                myamusashiPackages.serein
                myamusashiPackages.zapfast
                myamusashiPackages.qmlformat-rs
                myamusashiPackages.loaf-fm
                (wrapElectron pkgs.vesktop "vesktop")
                pkgs.opencode
                (wrapElectron inputs.helium.packages.${system}.default "helium")
                pkgs.bun
                pkgs.nodejs
                pkgs.luajitPackages.luacheck
                pkgs.lua5_5_compat
                pkgs.luajitPackages.lua-cjson
                pkgs.antigravity-cli
                (pkgs.callPackage ../../../packages/zcode-bridge.nix {})
                myamusashiPackages.omp
                (pkgs.callPackage ../../../packages/zcode.nix {})
                (pkgs.callPackage ../../../packages/zen-proxy.nix {})
                pkgs.git-credential-manager
                pkgs.gh
                pkgs.git
                pkgs.curl
                pkgs.kdiff3
                (pkgs.callPackage ../../../packages/app2unit.nix {})
                pkgs.sops
                pkgs.gvfs
                pkgs.wget2
                pkgs.vim
                pkgs.qbittorrent-enhanced-nox
                pkgs.nil
                pkgs.alejandra
                pkgs.statix
                pkgs.ollama-vulkan
                pkgs.libva
            ];

            sessionVariables = {
                HYPRCURSOR_THEME = "Future-Cyan-Hyprcursor_Theme";
                HYPRCURSOR_SIZE = "50";
                QS_ICON_THEME = "MoreWaita";
                QT_QPA_PLATFORMTHEME = "qtengine";
                XCURSOR_THEME = "Future-cursors";
                XCURSOR_SIZE = "35";
                QT_MEDIA_BACKEND = "ffmpeg";
                QT_FFMPEG_DECODING_HW_DEVICE_TYPES = "vaapi";
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
                AQ_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
                AQ_WLR_DEVICES = "/dev/dri/card1:/dev/dri/card0";
                AQ_MGPU_NO_EXPLICIT = 0;
                XDG_CONFIG_HOME = "/home/$USER/.config";
                XDG_MENU_PREFIX = "plasma-";
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
                "text/plain" = "nvim.desktop";
                "inode/directory" = "loaf.desktop";
                "application/x-gnome-saved-search" = "loaf.desktop";
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
                "text/x-log" = ["nvim.desktop"];
                "image/svg+xml" = ["lximage-qt.desktop.in"];
                "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
                "text/x-java-source" = ["nvim.desktop"];
                "image/jpeg" = ["lximage-qt.desktop.in"];
                "text/plain" = ["nvim.desktop"];
                "text/x-shellscript" = ["nvim.desktop"];
            };
        };
    };
}
