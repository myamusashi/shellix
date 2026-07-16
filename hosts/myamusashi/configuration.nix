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
    ];

    fonts = {
        packages = [
            inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro
            inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono
            inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny
            pkgs.maple-mono.NF
            pkgs.noto-fonts
            pkgs.weather-icons
            (import
            ../../modules/nixos/packages/custom/google-sans-flex.nix
            {inherit (pkgs) stdenv lib unzip;})
        ];
        enableDefaultPackages = true;
        fontconfig.defaultFonts = {
            serif = ["New York"];
            monospace = ["SF Mono"];
            sansSerif = ["SF Pro"];
        };
    };

    sops = {
        age.keyFile = lib.mkForce (userConfig + "/sops/age/keys1.txt");
    };

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Asia/Jakarta";

    # Nuh uh, don't fucking changing it
    system.stateVersion = "24.11"; # Did you read the comment?

    sops.secrets.myamusashi-password = {
        neededForUsers = true;
        owner = config.users.users.myamusashi.name;
    };

    services = {
        cloudflare-warp.enable = true;
        openssh.enable = true;
        xserver.xkb.layout = "us";
        nginx.enable = true;
        gnome.gnome-keyring.enable = false;
        gvfs.enable = true;
        upower.enable = true;
        mysql = {
            enable = true;
            package = pkgs.mariadb;
        };
    };

    security.pam.services.greetd.text = ''
        auth      substack      login
        account   include       login
        password  substack      login
        session   include       login
    '';

    programs = {
        quickshell-shell = {
            enable = true;
            installFonts = true;
        };
        starship.enable = true;
        dconf.enable = true;
        mtr.enable = true;
        nh = {
            enable = true;
            clean.enable = true;
        };
        git = {
            enable = true;
            config = {
                user.name = "myamusashi";
                user.email = "myamusashi@users.noreply.github.com";
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
            xwayland.enable = true;
            package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.overrideAttrs (old: {
                patches =
                    (old.patches or [])
                    ++ [
                        ../../overlays/patch/hyprland-patch/fix-loss-focus-window-on-closed-layer.patch
                    ];
            });
        };
        ccache.enable = true;
        java = {
            enable = true;
        };
        qtengine = {
            enable = true;

            config = {
                theme = {
                    colorScheme = "/run/current-system/sw/share/color-schemes/Darkly.colors";
                    iconTheme = "MoreWaita";
                    style = "qtengine";

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
            xdg-desktop-portal
            kdePackages.xdg-desktop-portal-kde
        ];
        config = {
            common.default = "hyprland;kde";
            pantheon.default = "kde";
        };
    };

    # broken ass
    # services.kmscon.enable = true;
    # services.kmscon.extraOptions = "--term xterm-256color --drm false --fbdev true";
}
