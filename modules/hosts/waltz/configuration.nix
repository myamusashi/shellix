flakeParts: let
    flakeConfig = flakeParts.config;
    inherit (flakeParts) inputs;
    nixosModules = flakeConfig.flake.modules.nixos;
in {
    flake.nixosConfigurations.waltz = inputs.nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
            nixosModules.coreBase
            nixosModules.nixSettings
            nixosModules.sopsBase
            nixosModules.servicePorts
            nixosModules.waltzHardware
            nixosModules.waltzNetworking
            nixosModules.waltzUsers
            nixosModules.cloudflared
            nixosModules.database
            nixosModules.forgejo
            nixosModules.ocis
            nixosModules.pihole
            nixosModules.vaultwarden
            nixosModules.vsftpd
            nixosModules.wireguardServer
            nixosModules.earlyoom
            nixosModules.borgBackupWaltz
            nixosModules.forgejoRunner
            nixosModules.eza
            nixosModules.fish
            nixosModules.git
            nixosModules.neovim
            nixosModules.nh
            nixosModules.nushell
            nixosModules.starship
            nixosModules.zoxide
            ({
                config,
                lib,
                pkgs,
                ...
            }: {
                nixpkgs.overlays = [
                    inputs.nix-cachyos-kernel.overlays.pinned
                ];

                nix.settings.trusted-users = ["waltz"];

                sops = {
                    age.keyFile = lib.mkForce "/home/waltz/.config/sops/age/keys.txt";
                    secrets = {
                        ocis_admin_pass.mode = "0440";
                        ocis_secrets_password.mode = "0440";
                        smtp_app_password.mode = "0440";
                        gmail_account.mode = "0440";
                        cloudflare_creds.path = "/var/lib/cloudflared/creds";
                        forgejo_runner_helium_token.path = "/var/lib/forgejo-runner/token/helium";
                        forgejo_runner_pgs_token.path = "/var/lib/forgejo-runner/token/pgs";
                        forgejo_runner_vast_token.path = "/var/lib/forgejo-runner/token/vast-shell";
                        forgejo_runner_yaziplgs_token.path = "/var/lib/forgejo-runner/token/yaziplgs";
                        waltz-password = {
                            path = "/var/lib/waltz/pass";
                            neededForUsers = false;
                        };
                        waltz-borg.path = "/var/lib/waltz/borg-secret";
                    };
                };

                shellix = {
                    wireguard = {
                        externalInterface = "enp1s0";
                        interface = "wg0";
                        address = "10.88.0.1/24";
                        privateKeyFile = "/etc/wireguard-keys/private.key";
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

                    pihole.listeningMode = "BIND";

                    cloudflared.ingress = {
                        "git.myamusashi.cc" = "unix:/run/forgejo/forgejo.sock";
                        "vault.myamusashi.cc" = "http://127.0.0.1:80";
                        "cloud.myamusashi.cc" = "https://localhost:${toString config.shellix.ports.ocis}";
                        "ssh.myamusashi.cc" = "ssh://localhost:22";
                    };

                    microvm = {
                        externalInterface = "enp1s0";
                        allowedBridgeTcpPorts = [config.shellix.ports.forgejo];
                    };

                    forgejoRunner = {
                        backend = "microvm";
                        runners = {
                            helium = {
                                url = "https://git.myamusashi.cc";
                                uuid = "41acf651-7136-420b-ab95-5ea4ae2b7b50";
                                tokenFile = config.sops.secrets.forgejo_runner_helium_token.path;
                                labels = [
                                    "nixos:host"
                                    "ubuntu-latest:host"
                                ];
                            };
                            presensi-guru-dan-siswa = {
                                url = "https://git.myamusashi.cc";
                                uuid = "19d73e81-9b87-4a79-8506-b10ee242d13f";
                                tokenFile = config.sops.secrets.forgejo_runner_pgs_token.path;
                                labels = [
                                    "nixos:host"
                                    "ubuntu-latest:host"
                                ];
                            };
                            vast-shell = {
                                url = "https://git.myamusashi.cc";
                                uuid = "7ea74882-6220-45d4-9738-25cc5ff3fdf2";
                                tokenFile = config.sops.secrets.forgejo_runner_vast_token.path;
                                labels = [
                                    "nixos:host"
                                    "ubuntu-latest:host"
                                ];
                            };
                            yazi-plugins = {
                                url = "https://git.myamusashi.cc";
                                uuid = "736956a8-7da5-4476-bd2e-fe3a396816a0";
                                tokenFile = config.sops.secrets.forgejo_runner_yaziplgs_token.path;
                                labels = [
                                    "nixos:host"
                                    "ubuntu-latest:host"
                                ];
                            };
                        };
                    };

                    neovim.languages = {
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
                        php = false;
                        nix = false;
                        data = false;
                        meson = false;
                    };

                    nushell = {
                        username = "waltz";
                        setAsDefaultShell = true;
                    };

                    fish = {
                        username = "waltz";
                        setAsDefaultShell = false;
                    };
                };

                security.acme.defaults.email = "security@myamusashi.cc";
                systemd.oomd.enable = lib.mkForce false;

                services = {
                    openssh = {
                        enable = true;
                        openFirewall = false;
                    };
                    logind.settings.Login.HandleLidSwitch = "ignore";
                    cloudflare-warp.enable = true;
                    kmscon = {
                        enable = true;
                        extraConfig = "font-name=Hack";
                    };
                    getty.autologinUser = "waltz";
                    nginx.virtualHosts."static.myamusashi.cc" = {
                        root = "/var/www/static";
                        locations."/".extraConfig = ''
                            autoindex on;
                        '';
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

                fonts.packages = [pkgs.nerd-fonts.hack];

                environment.systemPackages = [
                    pkgs.bat
                    pkgs.vim
                    pkgs.pciutils
                    pkgs.fzf
                    pkgs.inetutils
                    pkgs.duf
                    pkgs.forgejo-runner
                    pkgs.sops
                    pkgs.age
                    pkgs.alejandra
                    pkgs.unzip
                    pkgs.jq
                    pkgs.btop
                    pkgs.htop
                    pkgs.lazygit
                    pkgs.lazysql
                    pkgs.nil
                    pkgs.git
                    pkgs.gh
                    pkgs.curl
                    pkgs.cloudflared
                ];

                system.stateVersion = "24.11";
            })
        ];
    };
}
