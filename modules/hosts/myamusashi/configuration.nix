flakeParts: let
    flakeConfig = flakeParts.config;
    inherit (flakeParts) inputs;
    nixosModules = flakeConfig.flake.modules.nixos;
in {
    flake.nixosConfigurations.myamusashi = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
            nixosModules.coreBase
            nixosModules.nixSettings
            nixosModules.sopsBase
            nixosModules.myamusashiHardware
            nixosModules.myamusashiNetworking
            nixosModules.myamusashiUsers
            nixosModules.myamusashiPackages
            nixosModules.hyprland
            nixosModules.vastShell
            nixosModules.qtengine
            nixosModules.lightauth
            nixosModules.desktopFonts
            nixosModules.homeManagerMyamusashi
            nixosModules.audio
            nixosModules.easyeffects
            nixosModules.desktopOom
            nixosModules.kdeconnect
            nixosModules.samba
            nixosModules.scx
            nixosModules.steam
            nixosModules.colorTemplates
            nixosModules.resolver
            nixosModules.archbox
            nixosModules.borgBackupMyamusashi
            nixosModules.phpmyadmin
            nixosModules.btop
            nixosModules.direnv
            nixosModules.eza
            nixosModules.fish
            nixosModules.foot
            nixosModules.git
            nixosModules.gnupg
            nixosModules.htop
            nixosModules.kitty
            nixosModules.lazygit
            nixosModules.mpv
            nixosModules.neovim
            nixosModules.nh
            nixosModules.nushell
            nixosModules.starship
            nixosModules.yazi
            nixosModules.zoxide
            ({
                config,
                lib,
                pkgs,
                ...
            }: let
                userName = config.users.users.myamusashi.name;
                userConfigDirectory = "${config.users.users.myamusashi.home}/.config";
            in {
                nixpkgs = {
                    config.android_sdk.accept_license = true;
                    overlays = [
                        flakeConfig.flake.overlays.default
                        inputs.nix-cachyos-kernel.overlays.pinned
                        inputs.hyprpicker.overlays.default
                        inputs.hyprsunset.overlays.default
                        inputs.hyprland.overlays.default
                    ];
                };

                nix.settings.trusted-users = [
                    "root"
                    "myamusashi"
                ];

                sops = {
                    age.keyFile = lib.mkForce "${userConfigDirectory}/sops/age/keys1.txt";
                    secrets = {
                        proton-mail_account.mode = "0440";
                        lightauth_configs = {
                            path = "/home/myamusashi/.config/sops-nix/secrets/lightauth_configs";
                            owner = userName;
                        };
                        github_token = {
                            path = "/home/myamusashi/.config/sops-nix/secrets/github_token";
                            owner = userName;
                        };
                        firecrawl_api.owner = userName;
                        commandcode_api.owner = userName;
                        weatherapi.path = "/home/myamusashi/.config/sops-nix/secrets/weatherapi";
                        latitude.path = "/home/myamusashi/.config/sops-nix/secrets/latitude";
                        longitude.path = "/home/myamusashi/.config/sops-nix/secrets/longitude";
                        myamusashi-password = {
                            path = "/var/lib/myamusashi/pass";
                            neededForUsers = true;
                            owner = userName;
                        };
                        myamusashi-borg.path = "/var/lib/myamusashi/borg-secret";
                    };
                    templates."git-user-email" = {
                        content = ''
                            [user]
                                email = ${config.sops.placeholder.proton-mail_account}
                        '';
                        owner = userName;
                        mode = "0400";
                    };
                };

                shellix = {
                    easyeffects.preset = "gentle-dynamics";
                    archbox.user = "myamusashi";
                    colorTemplates.zenProfiles = [".zen/kxhdnjqx.zen"];
                    nushell = {
                        username = "myamusashi";
                        setAsDefaultShell = true;
                    };
                    fish = {
                        username = "myamusashi";
                        setAsDefaultShell = false;
                    };
                    neovim.languages = {
                        web = false;
                        python = false;
                        docker = false;
                        dart = false;
                        sql = false;
                        lint = false;
                    };
                };

                services = {
                    cloudflare-warp.enable = true;
                    openssh = {
                        enable = true;
                        openFirewall = false;
                    };
                    davfs2.enable = true;
                    xserver.xkb.layout = "us";
                    nginx.enable = true;
                    gnome.gnome-keyring.enable = true;
                    gvfs.enable = true;
                    upower.enable = true;
                    mysql = {
                        enable = true;
                        package = pkgs.mariadb;
                    };
                };

                security.polkit = {
                    enable = true;
                    enablePkexecWrapper = true;
                };

                programs = {
                    gpu-screen-recorder.enable = true;
                    dconf.enable = true;
                    thunderbird.enable = true;
                    mtr.enable = true;
                    ccache.enable = false;
                    java.enable = true;
                    nh.clean = {
                        enable = true;
                        extraArgs = "--quiet";
                    };
                    git = {
                        lfs.enable = true;
                        config = {
                            include.path = config.sops.templates."git-user-email".path;
                            user.name = "myamusashi";
                            alias = {
                                ci = "commit";
                                sw = "checkout";
                                s = "status";
                            };
                        };
                    };
                };

                systemd.timers."nh-clean".timerConfig.RandomizedDelaySec = "6h";

                system.stateVersion = "24.11";
            })
        ];
    };
}
