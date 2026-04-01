{
    config,
    pkgs-stable,
    lib,
    ...
}: {
    imports = [
        ./hardware/default.nix
        ../../modules/shared/Variable.nix
        ../../modules/packages/nixos-packages.nix
        ../../modules/programs/nixos/default.nix
        ../../modules/services/nixos/default.nix
        ../../modules/services/server/default.nix
    ];

    shellix = {
        services = {
            server = {
                database.enable = true;
                forgejo.enable = true;
                wireguard = {
                    enable = true;
                    externalInterfaces = "enp1s0";
                    wireguardInterfaces = "wg0";
                    pathPrivateKeyFile = "/etc/wireguard-keys/private.key";
                    peers = [
                        {
                            publicKey = "z9vwz2freR66r1sAybDlDz35ElSJhs1D5hMQKSJzlVw=";
                            allowedIPs = ["10.88.0.2/32"];
                        }
                        {
                            publicKey = "2Ql33s7ojKEQVd/mG2Aie+cM5wG37Nl9kAlzdD1p+CM=";
                            allowedIPs = ["10.88.0.3/32"];
                        }
                    ];
                };
                monitoring.enable = true;
                phpmyadmin.enable = false;
                vaultwarden.enable = true;
                vsftpd.enable = true;
                nextcloud.enable = true;
                nix-serve.enable = false;
            };
            nixos = {
                earlyoom.enable = false;
                backup.waltz.enable = true;
                resolver.enable = true;
            };
        };

        programs.nixos = {
            fish.enable = true;
            starship.enable = true;
            steam.enable = false;
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

            customPackages = with pkgs-stable; [
                sops
                borgbackup
                cachix
                age
                alejandra
                statix
                unzip
                ntfs3g
                jq
                btop
                htop
                lazygit
                lazyjournal
                lazysql
                openssl
                home-manager
                podman-compose
                nil
                nixd
                nixdoc
                nethogs
                zellij
            ];

            excludePackages = [
                "pinentry-qt"
                "pinentry-curses"
                "udisks"
                "udiskie"
                "gparted"
                "libvirt"
                "rich-cli"
                "power-profiles-daemon"
                "bluez"
                "mediainfo"
                "ouch"
                "glow"
                "hexyl"
                "antiprism"
                "wireshark"
                "networkmanagerapplet"
                "bitwarden-desktop"
                "pass-wayland"
                "kdiff3"
            ];
        };
    };

    programs = {
        kdeconnect.enable = true;
        wireshark.enable = lib.mkForce false;
        xonsh.enable = lib.mkForce false;
        steam.enable = lib.mkForce false;
    };

    services = {
        openssh.enable = true;
        xserver.xkb.layout = "us";
        logind.lidSwitch = "ignore";
        forgejo.settings.server.HTTP_PORT = lib.mkForce config.shellix.variables.port.FORGEJO;
        prometheus.port = lib.mkForce config.shellix.variables.port.PROMETHEUS;
        prometheus.exporters.node.port = lib.mkForce config.shellix.variables.port.PROMETHEUS-EXPORTERS;
        nginx.virtualHosts."dash.myamusashi.com".locations."/".proxyPass = lib.mkForce "http://127.0.0.1:${toString config.shellix.variables.port.GRAFANA}";
        nginx.virtualHosts."cloud.myamusashi.com".listen = [
            {
                addr = "127.0.0.1";
                port = lib.mkForce config.shellix.variables.port.NEXTCLOUD;
            }
        ];
        vaultwarden.config.ROCKET_PORT = lib.mkForce config.shellix.variables.port.VAULTWARDEN;
    };

    networking = {
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
        domain = "home.waltz.dev";
        search = ["home.waltz.dev"];
        interfaces = {
            enp1s0.ipv4.addresses = [
                {
                    address = "192.168.18.14";
                    prefixLength = 28;
                }
            ];
            waltz.ipv4.addresses = [
                {
                    address = "10.11.11.1";
                    prefixLength = 24;
                }
            ];
        };
        vlans = {
            waltz = {
                id = 2;
                interface = "enp1s0";
            };
        };
        nameservers = [
            "1.1.1.1#one.one.one.one"
            "1.0.0.1#one.one.one.one"
            "94.140.14.14"
            "94.140.15.15"
        ];

        hostName = "waltz";
        defaultGateway = {
            address = "192.168.18.1";
            interface = "enp1s0";
        };
        firewall = {
            enable = true;
            allowedTCPPorts = [20 21 22 2408 5432 3001 3002];
            allowedUDPPorts = [5432 3001 3002];
        };
    };

    sops.secrets.waltz-password.neededForUsers = false;
    sops.age.keyFile = lib.mkForce "/home/waltz/.config/sops/age/keys.txt";
    users.users.waltz = {
        isNormalUser = true;
        # hashedPasswordFile = config.sops.secrets.waltz-password.path;
        description = "waltz";
        shell = pkgs-stable.fish;
        extraGroups = ["networkmanager" "wheel" "vsftpd" "docker" "podman"];
    };

    users.groups.cloudflared = {};
    users.users.cloudflared = {
        isSystemUser = true;
        group = "cloudflared";
        description = "Cloudflare Tunnel service user";
        extraGroups = ["forgejo"];
    };

    users.groups.nextcloud = {};
    users.users.nextcloud = {
        isSystemUser = true;
        group = "nextcloud";
    };

    users.groups.netdata = {};
    users.users.netdata = {
        isSystemUser = true;
        group = "netdata";
    };

    users.groups.atticd = {};
    users.users.atticd = {
        isSystemUser = true;
        group = "atticd";
    };

    users.groups.forgejo-runner = {};
    users.users.forgejo-runner = {
        isNormalUser = true;
        group = "forgejo-runner";
        extraGroups = ["forgejo" "docker" "podman"];
    };

    time.timeZone = "Asia/Jakarta";
    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.11"; # Did you read the comment?

    nixpkgs = {
        config.allowUnfree = true;
    };
    nix = {
        package = pkgs-stable.nix;
        settings = {
            experimental-features = [
                "nix-command"
                "flakes"
            ];
            trusted-users = [
                "waltz"
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
        };
    };
    services.kmscon.enable = true;
    services.kmscon.fonts = [
        {
            name = "Hack";
            package = pkgs-stable.nerd-fonts.hack;
        }
    ];

    services.cloudflare-warp.enable = true;
}
