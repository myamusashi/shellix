{
    config,
    inputs,
    lib,
    pkgs,
    ...
}: let
    pinentryQtWrapped = pkgs.writeShellScriptBin "pinentry-qt" ''
        export QT_QPA_PLATFORMTHEME="${config.home.sessionVariables.QT_QPA_PLATFORMTHEME or "qtengine"}"
        export QT_STYLE_OVERRIDE="${config.home.sessionVariables.QT_STYLE_OVERRIDE or ""}"
        exec ${pkgs.pinentry-qt}/bin/pinentry-qt "$@"
    '';
    userHome = config.users.users.myamusashi.home;
    userConfig = userHome + "/.config";
in {
    imports = [
        inputs.shell.nixosModules.default
        inputs.qtengine.nixosModules.default
        inputs.hyprland.nixosModules.default
        inputs.lightauth.nixosModules.lightauth
        # inputs.sesame.nixosModules.default
    ];

    fonts = {
        packages = [
            inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro
            inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono
            inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny
            pkgs.maple-mono.NF
            pkgs.noto-fonts
            pkgs.weather-icons
            (pkgs.callPackage ../../modules/nixos/packages/custom/switzer-font.nix {})
            (pkgs.callPackage ../../modules/nixos/packages/custom/google-sans-flex.nix {})
        ];
        enableDefaultPackages = true;
        fontconfig = {
            enable = true;
            antialias = true;
            hinting = {
                enable = true;
                style = "slight"; # hintslight
                autohint = false;
            };
            subpixel = {
                rgba = "rgb"; # or "bgr" if your panel's subpixels are ordered that way
                lcdfilter = "default"; # lcddefault
            };
            defaultFonts = {
                serif = ["New York"];
                monospace = ["SF Mono"];
                sansSerif = ["SF Pro"];
            };
        };
    };

    sops = {
        age.keyFile = lib.mkForce (userConfig + "/sops/age/keys1.txt");
        secrets = {
            github_token.owner = config.users.users.myamusashi.name;
            firecrawl_api.owner = config.users.users.myamusashi.name;
            commandcode_api.owner = config.users.users.myamusashi.name;
            lightauth_configs.owner = config.users.users.myamusashi.name;
            myamusashi-password = {
                neededForUsers = true;
                owner = config.users.users.myamusashi.name;
            };
        };
    };

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Asia/Jakarta";

    # Nuh uh, don't fucking changing it
    system.stateVersion = "24.11"; # Did you read the comment?

    services = {
        cloudflare-warp.enable = true;
        openssh.enable = true;
        xserver.xkb.layout = "us";
        nginx.enable = true;
        gnome.gnome-keyring.enable = true;
        gvfs.enable = true;
        upower.enable = true;
        # sesamed = {
        #     enable = true;
        #     package = inputs.sesame.packages.${pkgs.stdenv.hostPlatform.system}.default;
        #     pamModule = "sddm";
        # };
        mysql = {
            enable = true;
            package = pkgs.mariadb;
        };
        lightauth = {
            enable = true;
            package = inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.lightauth;
            configFile = config.sops.secrets.lightauth_configs.path;
        };
    };

    security.polkit = {
        enable = true;
        enablePkexecWrapper = true;
    };

    programs = {
        quickshell-shell = {
            enable = true;
            installFonts = true;
            greetd = {
                enable = true;
                user = "myamusashi";
            };
        };
        gpu-screen-recorder.enable = true;
        dconf.enable = true;
        thunderbird.enable = true;
        mtr.enable = true;
        nh = {
            enable = true;
            clean = {
                enable = true;
                extraArgs = "--quiet";
            };
        };
        git = {
            enable = true;
            lfs.enable = true;
            config = {
                user = {
                    name = "myamusashi";
                    email = "myamusashi@users.noreply.github.com";
                };
                credential.helper = "store";
                alias = {
                    ci = "commit";
                    sw = "checkout";
                    s = "status";
                };
            };
        };
        direnv = {
            enable = true;
            nix-direnv.enable = true;
        };
        gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
            pinentryPackage = pinentryQtWrapped;
        };
        hyprland = {
            enable = true;
            package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
                patches =
                    (oldAttrs.patches or [])
                    ++ [
                        ../../0001-surface-fix-partial-damage-for-layer-surfaces-background-effects-and-hyprland-surfaces.patch
                    ];
            });
            portalPackage =
                inputs.xdg-desktop-portal-hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
        ccache.enable = false;
        java = {
            enable = true;
        };
        qtengine = {
            enable = true;

            config = {
                theme = {
                    colorScheme = "/home/myamusashi/.local/share/color-schemes/Shellix.colors";
                    iconTheme = "MoreWaita";
                    style = "darkly";

                    font = {
                        family = "SF Pro";
                        size = 11;
                        weight = -1;
                    };

                    fontFixed = {
                        family = "Maple Mono NF";
                        size = 11;
                        weight = -1;
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

    xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
            lxqt.xdg-desktop-portal-lxqt
            xdg-desktop-portal-gtk
            inputs.myamusashi-pkgs.packages.${stdenv.hostPlatform.system}.loaf-fm
        ];
        config = {
            common = {
                default = ["gtk"];
            };

            hyprland = {
                default = ["hyprland"];
                "org.freedesktop.impl.portal.FileChooser" = ["loaf"];
                "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
                "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
                "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
            };
        };
    };

    systemd.timers."nh-clean".timerConfig.RandomizedDelaySec = "6h";

    # broken ass
    # services.kmscon.enable = true;
    # services.kmscon.extraOptions = "--term xterm-256color --drm false --fbdev true";
}
