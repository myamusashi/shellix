{
    config,
    inputs,
    lib,
    pkgs,
    ...
}: let
    greeterPkg = inputs.shell-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;

    hyprConfig = pkgs.writeText "greetd-hyprland" ''
        exec-once = ${greeterPkg}/bin/shell && pkill Hyprland

        monitor = ,preferred, auto, auto
        env=XDG_CURRENT_DESKTOP,Hyprland
        misc {
           force_default_wallpaper = 1
           disable_hyprland_logo = true
         }
    '';

    # Fix ssh login not using qtengine
    pinentryQtWrapped = pkgs.writeShellScriptBin "pinentry-qt" ''
        export QT_QPA_PLATFORMTHEME="${config.home.sessionVariables.QT_QPA_PLATFORMTHEME or "qtengine"}"
        export QT_STYLE_OVERRIDE="${config.home.sessionVariables.QT_STYLE_OVERRIDE or ""}"
        exec ${pkgs.pinentry-qt}/bin/pinentry-qt "$@"
    '';
in {
    imports = [
        inputs.qtengine.nixosModules.default
        inputs.sops-nix.nixosModules.sops
        inputs.mangowc.nixosModules.mango
        ./hardware/default.nix
        ../../modules/shared/Colors.nix
        ../../modules/packages/nixos-packages.nix
        ../../modules/programs/nixos/default.nix
        ../../modules/services/nixos/default.nix
    ];
    sops = {
        age.keyFile = lib.mkForce "/home/myamusashi/.config/sops/age/keys1.txt";
        secrets = {
            weatherapi.owner = "myamusashi";
            latitude.owner = "myamusashi";
            longitude.owner = "myamusashi";
        };
    };

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Asia/Jakarta";

    # Nuh uh, don't fucking changing it
    system.stateVersion = "24.11"; # Did you read the comment?

    systemd.services.greetd.environment = {
        QML2_IMPORT_PATH = lib.concatStringsSep ":" [
            "${inputs.shell-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default}/${pkgs.qt6.qtbase.qtQmlPrefix}"
        ];
    };

    networking = {
        hostName = "nixos";
        defaultGateway = {
            address = "192.168.18.1";
            interface = "enp0s31f6";
        };
        dhcpcd.enable = false;
        networkmanager = {
            enable = true;
            dns = "systemd-resolved";
            insertNameservers = [
                "1.1.1.1#one.one.one.one"
                "1.0.0.1#one.one.one.one"
                "94.140.14.14" # adGuard
                "94.140.15.15"
            ];
        };
        domain = "home.myamusashi.dev";
        search = ["home.myamusashi.dev"];
        interfaces = {
            enp0s31f6.ipv4.addresses = [
                {
                    address = "192.168.18.2";
                    prefixLength = 28;
                }
            ];
            myamusashi.ipv4.addresses = [
                {
                    address = "10.10.10.1";
                    prefixLength = 24;
                }
            ];
        };
        vlans = {
            myamusashi = {
                id = 2;
                interface = "enp0s31f6";
            };
        };
        nameservers = [
            "192.168.18.4"
            "1.1.1.1#one.one.one.one"
            "1.0.0.1#one.one.one.one"
            "94.140.14.14"
            "94.140.15.15"
        ];
        extraHosts = ''
            127.0.0.1 pmo.com
        '';
        firewall = {
            enable = true;
            allowedTCPPorts = [
                22
            ];
            allowedUDPPorts = [
                22
                51820
            ];
            allowedUDPPortRanges = [
                {
                    from = 1714;
                    to = 1764;
                }
            ];
            allowedTCPPortRanges = [
                {
                    from = 1714;
                    to = 1764;
                }
            ];
        };
        wg-quick.interfaces = {
            wg0 = {
                mtu = 1420;
                address = lib.mkDefault ["10.88.0.3/32"];
                listenPort = 51820;
                dns = ["1.1.1.1"];
                privateKeyFile = "/etc/wireguard-keys/private.key";
                peers = [
                    {
                        publicKey = "IzirsljupeFXLusg6CooDzjSfc/xGVehBuJetADkaEU=";
                        allowedIPs = ["0.0.0.0/0"];
                        endpoint = "192.168.18.14:51820";
                    }
                ];
            };
        };
    };

    sops.secrets.myamusashi-password.neededForUsers = true;
    sops.secrets.myamusashi-password.owner = config.users.users.myamusashi.name;
    users = {
        users = {
            myamusashi = {
                isNormalUser = true;
                hashedPasswordFile = config.sops.secrets.myamusashi-password.path;
                shell = pkgs.fish;
                home = "/home/myamusashi";
                extraGroups = [
                    "networkmanager"
                    "wheel"
                    "docker"
                    "podman"
                    "libvirtd"
                    "qemu-libvirtd"
                    "kvm"
                    "adbusers"
                    "video"
                    "render"
                    "input"
                    "seat"
                    "wireshark"
                    "i2c"
                ];
            };

            greeter = {
                isSystemUser = true;
                group = "greeter";
            };

            docker = {
                isSystemUser = true;
                group = "docker";
            };
        };
        groups.docker = {};
        groups.greeter = {};
    };

    services = {
        cloudflare-warp.enable = true;
        openssh.enable = true;
        xserver.xkb.layout = "us";
    };

    security.pam.services.greetd.text = ''
        auth      substack      login
        account   include       login
        password  substack      login
        session   include       login
    '';

    shellix = {
        matugen.colors.enable = true;

        services.nixos = {
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
                        enable = true;
                        user = "myamusashi";
                        session = "hyprland.desktop";
                    };
                };
            };
        };

        programs.nixos = {
            fish.enable = true;
            starship.enable = true;
            steam.enable = true;
            virt-manager.enable = false;
            wireshark.enable = false;
            xonsh.enable = false;
        };

        packages.nixos = {
            enable = true;

            system = true;
            network = true;
            security = true;
            android = true;

            development = {
                containers = true;
                tools = true;
            };

            wayland = {
                core = true;
            };

            media = {
                screen_recorder = true;
            };

            theming = {
                icons = true;
            };

            customPackages = with pkgs; [
                kdePackages.qtmultimedia
                distrobox
                git-credential-manager
                sops
                libva-utils
                lxqt.pcmanfm-qt
                kdePackages.dolphin
                inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
                inputs.shell.packages.${pkgs.stdenv.hostPlatform.system}.default
                lxqt.pavucontrol-qt
                wl-screenrec
                gvfs
                wget2
                home-manager
                iptables
                greetd
                arduino
                ddcutil
                virtualgl
                vulkan-tools
                libva-utils
                maple-mono.NF
                (inputs.vermilion.packages.${pkgs.stdenv.hostPlatform.system}.vermilion.overrideAttrs (oldAttrs: {
                    pnpmDeps = pkgs.pnpm_10.fetchDeps {
                        inherit (oldAttrs) pname src;
                        hash = "sha256-pCMwbE7eYbaOOLhWfSQtjblVctOu7nCGnUal4SID+DQ=";
                        fetcherVersion = 2;
                    };
                }))
                flutter
                android-studio
                netbeans
                android-tools
                spotify
                (linux-wifi-hotspot.overrideAttrs (oldAttrs: {
                    patches = [
                        (pkgs.fetchpatch {
                            url = "https://github.com/lakinduakash/linux-wifi-hotspot/commit/a3fce4b3ee9371eeb7b300fa7e9f291d93986db3.patch";
                            hash = "sha256-4xQ3iRUlkNpoxHXABhMIgsoDY9nENN/9FtHD3UMyAhc=";
                        })
                    ];
                }))
            ];
            excludePackages = [
            ];
        };
    };

    environment.systemPackages = inputs.shell-greeter.packages.${pkgs.stdenv.hostPlatform.system}.runtimeDeps;

    programs = {
        fish.enable = true;
        dconf.enable = true;
        mtr.enable = true;
        gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
            pinentryPackage = pinentryQtWrapped;
        };
        hyprland.enable = true;
        mango.enable = true;
        ccache.enable = true;
        java = {
            enable = true;
        };
        qtengine = {
            enable = true;

            config = {
                theme = {
                    colorScheme = "${config.users.users.myamusashi.home}/.local/share/color-schemes/Shellix.colors";
                    iconTheme = "breeze-dark";
                    style = "Darkly";

                    font = {
                        family = "Google Sans Flex";
                        size = 11;
                    };

                    fontFixed = {
                        family = "Maple Mono NF";
                        size = 11;
                    };
                };

                misc = {
                    singleClickActivate = false;
                    menusHaveIcons = true;
                    shortcutsForContextMenus = true;
                };
            };
        };
    };

    services.gvfs.enable = true;
    # broken
    # services.kmscon.enable = true;
    # services.kmscon.extraOptions = "--term xterm-256color --drm false --fbdev true";

    environment.sessionVariables = {
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

        ANV_VIDEO_DECODE = 1;

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
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };

    xdg.mime = {
        enable = true;
        defaultApplications = {
            "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
            "text/plain" = "zen-browser.desktop";
            "inode/directory" = "pcmanfm-qt.desktop";
            "application/x-gnome-saved-search" = "pcmanfm-qt.desktop";
            "image/png" = "lximage-qt.desktop.in";
            "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
            "image/jpeg" = "lximage-qt.desktop.in";
        };

        addedAssociations = {
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["draw.desktop"];
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["impress.desktop"];
            "image/png" = ["lximage-qt.desktop.in" "yazi.desktop"];
            "text/x-log" = ["dev.zed.Zed.desktop"];
            "image/svg+xml" = ["lximage-qt.desktop.in"];
            "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
            "text/x-java-source" = ["dev.zed.Zed.desktop"];
            "image/jpeg" = ["lximage-qt.desktop.in"];
            "text/plain" = ["nvim.desktop"];
            "text/x-shellscript" = ["nvim.desktop"];
        };
    };

    nixpkgs = {
        config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
        };
    };
    nix = {
        enable = true;
        package = pkgs.nix;
        settings = {
            experimental-features = [
                "nix-command"
                "flakes"
            ];
            trusted-users = [
                "root"
                "myamusashi"
            ];
            substituters = [
                "https://myamusashi.cachix.org"
                "https://cache.nixos.org"
                "https://nix-community.cachix.org"
                "https://chaotic-nyx.cachix.org"
                "https://nix-community.cachix.org"
                "https://ezkea.cachix.org"
                "https://hyprland.cachix.org"
                "https://walker.cachix.org"
                "https://walker-git.cachix.org"
                "https://cache.flox.dev"
                ## cachyos kernel binary caches
                "https://attic.xuyh0120.win/lantian"
                "https://cache.garnix.io"
            ];

            extra-substituters = [
                # "https://cache.myamusashi.space"
            ];

            trusted-public-keys = [
                "myamusashi.cachix.org-1:ra4PbY6yqM1pSvkGqJ78CZse3WWgjk4rOXBMtjD9YrY="
                "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
                "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
                "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
                "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
                "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
                "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            ];

            extra-trusted-public-keys = [
                # "cache.myamusashi.space-1:7wJ0GThM/MBLSmvDw8u8Y0XMiXAshFmX1Hz1jJ0PKWg="
            ];
        };
    };

    services.mysql = {
        enable = true;
        package = pkgs.mariadb;
    };
}
