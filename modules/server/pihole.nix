{
    lib,
    config,
    pkgs-stable,
    ...
}: let
    cfg = config.shellix.server.pihole;
    wgEnabled = config.shellix.server.wireguard.enable or false;
    wgIf = config.shellix.server.wireguard.wireguardInterfaces or "wg0";
    wgAddress = config.shellix.server.wireguard.wireguardAddress or "10.88.0.1/24";
    wgIp = lib.head (lib.splitString "/" wgAddress);
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
            description = "Pi-hole dns.listeningMode — LOCAL = only local subnets (safe for LAN/WG), ALL = open resolver (firewall it!)";
        };
    };
    config = lib.mkIf cfg.enable {
        warnings =
            lib.optional (wgEnabled && cfg.interface != "" && cfg.interface != wgIf)
            "shellix.server.pihole.interface='${cfg.interface}' does not include WireGuard interface '${wgIf}': WG peers at ${wgIp} may not reach Pi-hole. Set interface=\"\" or interface=\"${wgIf}\" or use listeningMode=LOCAL with interface=\"\"."
            ++ lib.optional (wgEnabled && cfg.listeningMode == "SINGLE")
            "shellix.server.pihole.listeningMode=SINGLE will only answer on one interface — WG DNS from ${wgIf} will be REFUSED. Use LOCAL or ALL for WireGuard integration."
            ++ lib.optional (wgEnabled && cfg.listeningMode == "BIND" && cfg.interface == "")
            "shellix.server.pihole.listeningMode=BIND with interface=\"\" will bind all interfaces but BIND requires explicit interface — Pi-hole may fail to start. Set interface=\"${wgIf}\" or switch to LOCAL.";

        assertions = [
            {
                assertion =
                    !(wgEnabled && cfg.listeningMode == "SINGLE" && cfg.interface != wgIf && cfg.interface != "");
                message = "Pi-hole SINGLE mode with interface=${cfg.interface} cannot serve WireGuard ${wgIf} (${wgIp}). Fix: listeningMode=LOCAL or interface=${wgIf}/\"\"";
            }
        ];

        # Pi-hole owns port 53, disable conflicting resolvers
        services.resolved.enable = lib.mkForce false;
        services.dnsmasq.enable = lib.mkForce false;
        shellix.services.resolver.enable = lib.mkForce false;

        # Host itself uses Pi-hole
        networking.nameservers = lib.mkForce ["127.0.0.1"];
        networking.networkmanager.dns = lib.mkForce "default";

        environment.systemPackages = with pkgs-stable; [
            pihole
        ];

        services.pihole-ftl = {
            enable = true;
            openFirewallDNS = true;
            openFirewallDHCP = false;
            # useDnsmasqConfig = false; # we disabled dnsmasq

            settings = {
                dns = {
                    upstreams = [
                        "1.1.1.1#53"
                        "1.0.0.1#53"
                    ];
                    # LOCAL = only queries from local subnets (enp1s0 192.168.18.0/28, waltz vlan 10.11.11.0/24, wg0 10.88.0.0/24, lo)
                    listeningMode = cfg.listeningMode;
                    interface = cfg.interface;
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
                };
                dhcp.active = false;
            };

            # Curated blocklists — added via API on first boot (requires webserver)
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

        services.pihole-web = {
            enable = true;
            ports = [cfg.webPort];
            hostName = "pi.hole";
        };

        # Firewall — DNS + web dashboard
        # When WireGuard is enabled, explicitly allow DNS on wg interface so peers
        # at 10.88.0.0/24 can reach Pi-hole even if global firewall is tightened.
        # WireGuard peers should set DNS=${wgIp} (e.g. DNS=10.88.0.1 in wg-quick).
        networking.firewall =
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

        # Ensure Pi-hole starts after WG interface exists when BIND/SINGLE pin to wgIf,
        # and generally prefer WG up before DNS (harmless for LOCAL/ALL).
        systemd.services.pihole-ftl.after = lib.optional wgEnabled "wg-quick-${wgIf}.service";
        systemd.services.pihole-ftl.wants = lib.optional wgEnabled "wg-quick-${wgIf}.service";

        # Ensure gravity DB is populated on first boot; optional timer
        systemd.services.pihole-gravity-update = {
            description = "Pi-hole gravity update";
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs-stable.pihole}/bin/pihole -g";
                User = "pihole";
            };
        };

        systemd.timers.pihole-gravity-update = {
            description = "Weekly Pi-hole gravity update";
            wantedBy = ["timers.target"];
            timerConfig = {
                OnCalendar = "weekly";
                Persistent = true;
            };
        };
    };
}
