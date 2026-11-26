flakeParts: let
    flakeConfig = flakeParts.config;
in {
    flake.modules.nixos.pihole = {
        config,
        lib,
        pkgs,
        ...
    }: let
        piholeConfig = config.shellix.pihole;
        wireguardEnabled = config.networking.wg-quick.interfaces != {};
        wireguardInterface = lib.attrByPath ["shellix" "wireguard" "interface"] "wg0" config;
        wireguardAddress = lib.attrByPath ["shellix" "wireguard" "address"] "10.88.0.1/24" config;
        wireguardIpAddress = lib.head (lib.splitString "/" wireguardAddress);

        # Upstream pihole-ftl module reads `piholePackage.src.src.tag` while newer nixpkgs exposes `src.tag`.
        piholePackage = pkgs.pihole.overrideAttrs (previous: let
            originalSource = previous.passthru.src or previous.src;
        in {
            passthru =
                (previous.passthru or {})
                // {
                    src =
                        originalSource
                        // {
                            src = originalSource.src or originalSource;
                        };
                };
        });
    in {
        key = "shellix.nixos.pihole";

        imports = [
            flakeConfig.flake.modules.nixos.servicePorts
        ];

        options.shellix.pihole = {
            webPort = lib.mkOption {
                type = lib.types.port;
                default = config.shellix.ports.pihole;
                description = "Port for Pi-hole web dashboard.";
            };

            interface = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Interface Pi-hole binds to (empty means all interfaces allowed by listeningMode).";
            };

            listeningMode = lib.mkOption {
                type = lib.types.enum [
                    "LOCAL"
                    "ALL"
                    "SINGLE"
                    "BIND"
                ];
                default = "LOCAL";
                description = "Pi-hole dns.listeningMode (BIND avoids wildcard :53 so bridge resolvers keep their own port).";
            };

            extraDnsmasqLines = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                example = ["except-interface=podman0"];
                description = "Extra dnsmasq lines appended to Pi-hole FTL misc.dnsmasq_lines.";
            };
        };

        config = {
            warnings =
                lib.optional (wireguardEnabled && piholeConfig.interface != "" && piholeConfig.interface != wireguardInterface)
                "shellix.pihole.interface='${piholeConfig.interface}' does not include WireGuard interface '${wireguardInterface}': peers at ${wireguardIpAddress} may not reach Pi-hole."
                ++ lib.optional (wireguardEnabled && piholeConfig.listeningMode == "SINGLE")
                "shellix.pihole.listeningMode=SINGLE answers only one interface; WireGuard DNS from ${wireguardInterface} will be refused."
                ++ lib.optional (wireguardEnabled && piholeConfig.listeningMode == "BIND" && piholeConfig.interface != "")
                "shellix.pihole.listeningMode=BIND with interface='${piholeConfig.interface}' pins to a single interface; leave interface empty to serve LAN and WireGuard.";

            assertions = [
                {
                    assertion = !(wireguardEnabled && piholeConfig.listeningMode == "SINGLE" && piholeConfig.interface != wireguardInterface && piholeConfig.interface != "");
                    message = "Pi-hole SINGLE mode with interface=${piholeConfig.interface} cannot serve WireGuard ${wireguardInterface} (${wireguardIpAddress}).";
                }
            ];

            networking = {
                nameservers = lib.mkForce ["127.0.0.1"];
                networkmanager.dns = lib.mkForce "default";

                firewall =
                    {
                        allowedTCPPorts = [
                            53
                            piholeConfig.webPort
                        ];
                        allowedUDPPorts = [53];
                    }
                    // lib.optionalAttrs wireguardEnabled {
                        interfaces.${wireguardInterface} = {
                            allowedTCPPorts = [53];
                            allowedUDPPorts = [53];
                        };
                    };
            };

            environment.systemPackages = [piholePackage];

            services = {
                resolved.enable = lib.mkForce false;
                dnsmasq.enable = lib.mkForce false;

                pihole-ftl = {
                    enable = true;
                    inherit piholePackage;
                    openFirewallDNS = true;
                    openFirewallDHCP = false;

                    settings = {
                        dns = {
                            upstreams = [
                                "1.1.1.1#53"
                                "1.0.0.1#53"
                            ];
                            inherit (piholeConfig) listeningMode interface;
                            domainNeeded = true;
                            bogusPriv = true;
                            dnssec = false;
                            queryLogging = true;
                        };
                        webserver.api.cli_pw = true;
                        misc = {
                            privacylevel = 0;
                            dnsmasq_lines = piholeConfig.extraDnsmasqLines;
                        };
                        dhcp.active = false;
                    };

                    lists = [
                        {url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";}
                        {url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.plus.txt";}
                        {url = "https://urlhaus.abuse.ch/downloads/hostfile/";}
                        {url = "https://threatfox.abuse.ch/downloads/hostfile/";}
                        {url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.txt";}
                        {url = "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/hoster.txt";}
                        {url = "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/malware";}
                        {url = "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt";}
                    ];
                };

                pihole-web = {
                    enable = true;
                    ports = [piholeConfig.webPort];
                    hostName = "pi.hole";
                };
            };

            systemd = {
                services = {
                    pihole-ftl = {
                        after = lib.optional wireguardEnabled "wg-quick-${wireguardInterface}.service";
                        wants = lib.optional wireguardEnabled "wg-quick-${wireguardInterface}.service";
                    };

                    pihole-gravity-update = {
                        description = "Pi-hole gravity update";
                        serviceConfig = {
                            Type = "oneshot";
                            ExecStart = "${piholePackage}/bin/pihole -g";
                            User = "pihole";
                        };
                    };
                };
                timers.pihole-gravity-update = {
                    description = "Weekly Pi-hole gravity update";
                    wantedBy = ["timers.target"];
                    timerConfig = {
                        OnCalendar = "weekly";
                        Persistent = true;
                    };
                };
            };
        };
    };
}
