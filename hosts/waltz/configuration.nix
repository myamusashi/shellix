{
    config,
    pkgs-stable,
    lib,
    ...
}: {
    imports = [
        ./hardware/default.nix
        ../../shared/Variable.nix
        ../../modules/nixos/programs/default.nix
        ../../modules/nixos/services/default.nix
        ../../modules/server/default.nix
    ];

    shellix = {
        server = {
            mail.enable = false;
            database.enable = true;
            forgejo.enable = true;
            wireguard = {
                enable = true;
                externalInterfaces = "enp1s0";
                wireguardInterfaces = "wg0";
                wireguardAddress = "10.88.0.1/24";
                pathPrivateKeyFile = "/etc/wireguard-keys/private.key";
                peers = [
                    {
                        publicKey = "DwqntR+HaHhiTST1MxZOYBKa0inDiUKN4HNo4UTeRHo=";
                        allowedIPs = ["10.88.0.2/32"];
                    }
                    {
                        publicKey = "2Ql33s7ojKEQVd/mG2Aie+cM5wG37Nl9kAlzdD1p+CM=";
                        allowedIPs = ["10.88.0.3/32"];
                    }
                ];
            };
            monitoring.enable = false;
            vaultwarden.enable = true;
            vsftpd.enable = true;
            ocis.enable = true;
            "9router".enable = false;
            headroom.enable = true;
            cloudflared = {
                enable = true;
                ingress = {
                    "git.myamusashi.cc" = "unix:/run/forgejo/forgejo.sock";
                    "vault.myamusashi.cc" = "http://127.0.0.1:${toString config.shellix.variables.port.VAULTWARDEN}";
                    "cloud.myamusashi.cc" = "https://localhost:${toString config.shellix.variables.port.OCIS}";
                    "ssh.myamusashi.cc" = "ssh://localhost:22";
                    "router.myamusashi.cc" = "http://127.0.0.1:${toString config.shellix.variables.port.NINEROUTER}";
                    "headroom.myamusashi.cc" = "http://127.0.0.1:${toString config.shellix.variables.port.HEADROOM}";
                };
            };
            phpApps = {
                enable = false;

                apps.example = {
                    enable = false;
                    version = "1.0.0";

                    vHostDomain = "example.com";
                    subdomain = "example";
                    listenAddress = "127.0.0.1";
                    port = 8801;

                    src = pkgs-stable.fetchFromForgejo {
                        domain = "git.myamusashi.cc";
                        owner = "myamusashi";
                        repo = "REDACTED_REPO";
                        rev = "7c00e04be3df87d10607be9840f2880c918a1274";
                        hash = "sha256-aAvrxBeLrZdh8TGNvH7PHd3czOeStA4XSPXmZnc9puY=";
                    };

                    phpPackage = pkgs-stable.php83;
                    phpExtensions = all:
                        with all; [
                            pdo
                            pdo_mysql
                            mysqli
                            mbstring
                            gd
                            curl
                            zip
                        ];

                    phpOptions = {
                        upload_max_filesize = "16M";
                        post_max_size = "16M";
                        memory_limit = "128M";
                    };

                    fpmSettings = {
                        "pm" = "dynamic";
                        "pm.max_children" = "10";
                        "pm.start_servers" = "3";
                        "pm.min_spare_servers" = "2";
                        "pm.max_spare_servers" = "5";
                    };

                    database = {
                        enable = true;
                        name = "REDACTED_DB";
                    };
                };
                apps.example = {
                    enable = false;
                    version = "1.0.0";

                    vHostDomain = "example.com";
                    subdomain = "example";
                    listenAddress = "127.0.0.1";
                    port = 8800;

                    src = pkgs-stable.fetchFromGitHub {
                        owner = "REDACTED_OWNER";
                        repo = "REDACTED_REPO";
                        rev = "92508d1f25a983fad758e79002b3ed111d2196ab";
                        hash = "sha256-xcP4YBR3N4AhGlwRJgopfifhBm3GC8XQKXTmExOLCXs=";
                    };

                    patches = [./pathshit.patch];
                    phpPackage = pkgs-stable.php83;
                    phpExtensions = all:
                        with all; [
                            pdo
                            pdo_mysql
                            mysqli
                            mbstring
                            gd
                            curl
                            zip
                        ];

                    phpOptions = {
                        upload_max_filesize = "16M";
                        post_max_size = "16M";
                        memory_limit = "128M";
                    };

                    fpmSettings = {
                        "pm" = "dynamic";
                        "pm.max_children" = "10";
                        "pm.start_servers" = "3";
                        "pm.min_spare_servers" = "2";
                        "pm.max_spare_servers" = "5";
                    };

                    database = {
                        enable = true;
                        name = "REDACTED_DB";
                    };
                };
            };
        };
        services = {
            earlyoom.enable = false;
            backup.waltz.enable = true;
            resolver.enable = true;
            forgejo-runner = {
                enable = true;
                runners = {
                    helium = {
                        url = "https://git.myamusashi.cc";
                        uuid = "41acf651-7136-420b-ab95-5ea4ae2b7b50";
                        tokenFile = config.sops.secrets.forgejo_runner_helium_token.path;
                    };
                    presensi-guru-dan-siswa = {
                        url = "https://git.myamusashi.cc";
                        uuid = "19d73e81-9b87-4a79-8506-b10ee242d13f";
                        tokenFile = config.sops.secrets.forgejo_runner_pgs_token.path;
                    };
                    vast-shell = {
                        url = "https://git.myamusashi.cc";
                        uuid = "7ea74882-6220-45d4-9738-25cc5ff3fdf2";
                        tokenFile = config.sops.secrets.forgejo_runner_vast_token.path;
                    };
                    yazi-plugins = {
                        url = "https://git.myamusashi.cc";
                        uuid = "736956a8-7da5-4476-bd2e-fe3a396816a0";
                        tokenFile = config.sops.secrets.forgejo_runner_yaziplgs_token.path;
                    };
                };
            };
        };

        programs = {
            neovim = {
                enable = true;

                languages = {
                    web = false;
                    lua = false;
                    lint = false;
                    cpp = false;
                    sql = false;
                    fish = false;
                    python = false;
                    bash = false;
                    qml = false;
                    docker = false;
                    dart = false;
                    markdown = false;
                };
            };
            nushell = {
                enable = true;
                username = "waltz";
                setAsDefaultShell = true;
            };
            fish = {
                enable = true;
                username = "waltz";
                setAsDefaultShell = false;
            };
        };
    };

    programs = {
        git = {
            enable = true;
            config = {
                credential.helper = "store";
            };
        };
    };

    security.acme.defaults.email = "security@myamusashi.cc";

    boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkForce 1;
    networking.nftables = {
        enable = true;
        ruleset = ''
            table ip nat {
              chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
                oifname "enp1s0" masquerade
              }
            }
        '';
    };

    qt.platformTheme = "lxqt";
    xdg.portal.lxqt.styles = pkgs-stable.breeze-qt5;
    xdg.portal.lxqt.enable = true;
    programs.gnupg.agent.pinentryPackage = pkgs-stable.pinentry-qt;

    services = {
        openssh.enable = true;
        xserver.desktopManager.lxqt.enable = true;
        logind.settings.Login.HandleLidSwitch = "ignore";
        cloudflare-warp.enable = true;
        create_ap = {
            enable = true;
            settings = {
                INTERNET_IFACE = "enp1s0";
                PASSPHRASE = "12345678";
                SSID = "nixos waltz";
                WIFI_IFACE = "wlp2s0";
            };
        };
        kmscon = {
            enable = true;
            config.font-name = "Hack";
        };
        getty = {
            enable = true;
            autologinUser = "waltz";
        };
        vaultwarden.config.ROCKET_PORT = lib.mkForce config.shellix.variables.port.VAULTWARDEN;
        forgejo.settings.server.HTTP_PORT = lib.mkForce config.shellix.variables.port.FORGEJO;
        prometheus = {
            port = lib.mkForce config.shellix.variables.port.PROMETHEUS;
            exporters.node.port = lib.mkForce config.shellix.variables.port.PROMETHEUS-EXPORTERS;
        };
        nginx.virtualHosts = {
            "dash.myamusashi.com".locations."/".proxyPass =
                lib.mkForce "http://0.0.0.0:${toString config.shellix.variables.port.GRAFANA}";
            "static.myamusashi.cc" = {
                root = "/var/www/static";
                locations."/" = {
                    extraConfig = ''
                        autoindex on;
                    '';
                };
            };
        };
        chrony = {
            enable = true;
            servers = ["pool.ntp.org"];
            enableRTCTrimming = false;
            extraConfig = ''
                makestep 1 -1
                rtcsync
            '';
        };
    };

    systemd.tmpfiles.rules = [
        "d /var/www/static 0755 nginx nginx"
    ];

    networking = {
        networkmanager = {
            enable = true;
            dns = "systemd-resolved";
            unmanaged = ["interface-name:wlp2s0"];
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
            allowedTCPPorts = [
                20
                21
                22
                25
                53
                80
                443
                465
                587
                993
                2408
                3306
                5432
                3001
                3002
                9200
                6764
                6753
                7597
                7916
                8080
                8131
                8787
                20128
            ];
            allowedUDPPorts = [
                53
                67
                68
                5353
                5432
                3001
                3002
                51820
            ];
        };
    };

    fonts.packages = [
        pkgs-stable.nerd-fonts.hack
    ];

    sops = {
        secrets.waltz-password.neededForUsers = false;
        age.keyFile = lib.mkForce "/home/waltz/.config/sops/age/keys.txt";
    };

    users = {
        users = {
            # nginx.extraGroups = ["simaset"];
            waltz = {
                isNormalUser = true;
                description = "waltz";
                extraGroups = [
                    "networkmanager"
                    "wheel"
                    "vsftpd"
                    "docker"
                    "podman"
                ];
            };
            cloudflared = {
                isSystemUser = true;
                group = "cloudflared";
                description = "Cloudflare Tunnel service user";
                extraGroups = ["forgejo"];
            };
            ocis = {
                isSystemUser = true;
                group = "ocis";
            };
            nginx = {
                isSystemUser = true;
                group = "nginx";
            };
            netdata = {
                isSystemUser = true;
                group = "netdata";
            };
            atticd = {
                isSystemUser = true;
                group = "atticd";
            };
            runner = {
                isNormalUser = true;
                group = "runner";
                extraGroups = [
                    "forgejo"
                    "docker"
                    "podman"
                ];
            };
        };
        groups = {
            cloudflared = {};
            ocis = {};
            netdata = {};
            atticd = {};
            nginx = {};
            runner = {};
        };
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
                "https://cache.xinux.uz"
                "https://attic.xuyh0120.win/lantian"
            ];

            extra-substituters = [
                # "https://cache.myamusashi.cc"
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
                "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
                "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
            ];
        };
    };
}
