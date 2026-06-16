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
        inputs.qtengine.nixosModules.default
    ];

    fonts = {
        enableDefaultPackages = true;
        fontconfig.defaultFonts = {
            serif = ["Segoe UI"];
            monospace = ["Maple Mono NF"];
            sansSerif = ["Segoe UI"];
        };
    };

    sops = {
        age.keyFile = lib.mkForce (userConfig + "/sops/age/keys1.txt");
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
            package = pkgs.hyprland;
            systemd.setPath.enable = true;
            portalPackage = pkgs.xdg-desktop-portal-hyprland;
            xwayland.enable = true;
        };
        ccache.enable = true;
        java = {
            enable = true;
        };
        qtengine = {
            enable = true;

            config = {
                theme = {
                    colorScheme = "/run/current-system/sw/share/color-schemes/Aero.colors";
                    iconTheme = "Windows 7 Aero";
                    style = "MS Windows 9x";

                    font = {
                        family = "Segoe UI";
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
            xdg-desktop-portal-hyprland
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
