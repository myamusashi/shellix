{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.server.pihole;
    wgEnabled = config.shellix.server.wireguard.enable or false;
    wgIf = config.shellix.server.wireguard.wireguardInterfaces or "wg0";
    wgAddress = config.shellix.server.wireguard.wireguardAddress or "10.88.0.1/24";
    wgIp = lib.head (lib.splitString "/" wgAddress);

    # Workaround for upstream nixpkgs pihole-ftl.nix referencing
    # `cfg.piholePackage.src.src.tag` while unstable `pkgs.pihole` exposes `src.tag` directly.
    piholePkg = pkgs.pihole.overrideAttrs (old: let
        origSrc = old.passthru.src or old.src;
    in {
        passthru =
            (old.passthru or {})
            // {
                src =
                    origSrc
                    // {
                        src = origSrc.src or origSrc;
                    };
            };
    });
in {
    options.shellix.server.pihole = {
        webPort = lib.mkOption {
            type = lib.types.port;
            default = 8080;
            description = "Port for Pi-hole web dashboard (pihole-web).";
        };

        interface = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Interface Pi-hole should bind to (empty = all, respects listeningMode).";
        };

        listeningMode = lib.mkOption {
            type = lib.types.enum [
                "LOCAL"
                "ALL"
                "SINGLE"
                "BIND"
            ];
            default = "LOCAL";
            description = "Pi-hole dns.listeningMode — LOCAL = only local subnets (safe for LAN/WG), ALL = open resolver (firewall it!). BIND = per-interface bind, no wildcard :53 — REQUIRED on container hosts so aardvark-dns/libvirt can bind their own :53 on podman/bridge interfaces.";
        };
        extraDnsmasqLines = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            example = ["except-interface=podman0"];
            description = "Extra dnsmasq lines appended to Pi-hole FTL misc.dnsmasq_lines (escape hatch, e.g. except-interface for container bridges).";
        };
    };
    config = lib.mkIf cfg.enable {
        warnings =
            lib.optional (wgEnabled && cfg.interface != "" && cfg.interface != wgIf)
            "shellix.server.pihole.interface='${cfg.interface}' does not include WireGuard interface '${wgIf}': WG peers at ${wgIp} may not reach Pi-hole. Set interface=\"\" or interface=\"${wgIf}\" or use listeningMode=LOCAL with interface=\"\"."
            ++ lib.optional (wgEnabled && cfg.listeningMode == "SINGLE")
            "shellix.server.pihole.listeningMode=SINGLE will only answer on one interface — WG DNS from ${wgIf} will be REFUSED. Use LOCAL or ALL for WireGuard integration."
            ++ lib.optional (wgEnabled && cfg.listeningMode == "BIND" && cfg.interface != "")
            "shellix.server.pihole.listeningMode=BIND pins to interface='${cfg.interface}' only — WG DNS from ${wgIf} will be REFUSED unless that is ${wgIf}. Use interface=\"\" (auto-detect, needs WG up first) to serve LAN+WG.";

        assertions = [
            {
                assertion =
                    !(wgEnabled && cfg.listeningMode == "SINGLE" && cfg.interface != wgIf && cfg.interface != "");
                message = "Pi-hole SINGLE mode with interface=${cfg.interface} cannot serve WireGuard ${wgIf} (${wgIp}). Fix: listeningMode=LOCAL or interface=${wgIf}/\"\"";
            }
        ];

        # Host itself uses Pi-hole
        networking = {
            nameservers = lib.mkForce ["127.0.0.1"];
            networkmanager.dns = lib.mkForce "default";

            # When WireGuard is enabled, explicitly allow DNS on wg interface so peers
            # at 10.88.0.0/24 can reach Pi-hole even if global firewall is tightened.
            firewall =
                {
                    allowedTCPPorts = [
                        53
                        cfg.webPort
                    ];
                    allowedUDPPorts = [53];
                }
                // lib.optionalAttrs wgEnabled {
                    interfaces.${wgIf} = {
                        allowedTCPPorts = [53];
                        allowedUDPPorts = [53];
                    };
                };
        };

        environment.systemPackages = [
            piholePkg
        ];

        # Pi-hole owns port 53, disable conflicting resolvers
        shellix.services.resolver.enable = lib.mkForce false;
        services = {
            resolved.enable = lib.mkForce false;
            dnsmasq.enable = lib.mkForce false;

            pihole-ftl = {
                enable = true;
                piholePackage = piholePkg;
                openFirewallDNS = true;
                openFirewallDHCP = false;
                # useDnsmasqConfig = false; # we disabled dnsmasq

                settings = {
                    dns = {
                        upstreams = [
                            "1.1.1.1#53"
                            "1.0.0.1#53"
                        ];
                        # waltz: BIND = per-interface bind (no wildcard :53) so container bridges keep their own :53.
                        # Answers queries from local subnets (enp1s0 192.168.18.0/28, waltz vlan 10.11.11.0/24, wg0 10.88.0.0/24, lo).
                        inherit (cfg) listeningMode interface;
                        domainNeeded = true;
                        bogusPriv = true;
                        dnssec = false;
                        queryLogging = true;
                        # hostRecord example: expose waltz itself
                        # hosts = [ "192.168.18.14 waltz.home.waltz.dev" ];
                    };
                    webserver = {
                        # pihole-web will set domain/port/paths; keep cli_pw true for gravity updates via API
                        api.cli_pw = true;
                    };
                    misc = {
                        privacylevel = 0;
                        dnsmasq_lines = cfg.extraDnsmasqLines;
                    };
                    dhcp.active = false;
                };

                # Curated blocklists — added via API on first boot
                lists = [
                    {
                        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
                    }
                    {
                        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.plus.txt";
                    }
                    {
                        url = "https://urlhaus.abuse.ch/downloads/hostfile/";
                    }
                    {
                        url = "https://threatfox.abuse.ch/downloads/hostfile/";
                    }
                    {
                        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.txt";
                    }
                    {
                        url = "https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/hoster.txt";
                    }
                    {
                        url = "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/malware";
                    }
                    {
                        url = "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt";
                    }
                ];
            };

            pihole-web = {
                enable = true;
                ports = [cfg.webPort];
                hostName = "pi.hole";
            };
        };

        # Ensure Pi-hole starts after WG interface exists when BIND/SINGLE pin to wgIf,
        # and generally prefer WG up before DNS (harmless for LOCAL/ALL).
        systemd = {
            services = {
                pihole-ftl = {
                    after = lib.optional wgEnabled "wg-quick-${wgIf}.service";
                    wants = lib.optional wgEnabled "wg-quick-${wgIf}.service";
                };

                pihole-gravity-update = {
                    description = "Pi-hole gravity update";
                    serviceConfig = {
                        Type = "oneshot";
                        ExecStart = "${piholePkg}/bin/pihole -g";
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
}
