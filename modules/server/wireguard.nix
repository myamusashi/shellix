{
    lib,
    config,
    pkgs-stable,
    ...
}: let
    cfg = config.shellix.server.wireguard;
    wgAddressParts = lib.splitString "/" cfg.wireguardAddress;
    wgAddressIP = lib.head wgAddressParts;
    wgAddressPrefix = lib.last wgAddressParts;
    wgSubnet = "${lib.concatStringsSep "." (lib.init (lib.splitString "." wgAddressIP))}.0/${wgAddressPrefix}";
    # Auto-detect Pi-hole: when enabled, Pi-hole owns :53 and becomes WG DNS
    piholeEnabled = config.shellix.server.pihole.enable or false;

    # Effective DNS for WireGuard peers — always the WG gateway IP, but
    # upstream differs: Pi-hole (filtered) vs dnsmasq → 1.1.1.1
    wgDnsIp = wgAddressIP;
    effectiveDns =
        if cfg.dns != null
        then cfg.dns
        else [wgDnsIp];
in {
    options.shellix.server.wireguard = {
        pathPrivateKeyFile = lib.mkOption {
            type = lib.types.path;
            default = "";
            example = "/etc/wireguard-keys/private";
            description = "Absolute path for private key";
        };
        externalInterfaces = lib.mkOption {
            type = lib.types.str;
            default = "enp1s0";
            example = "eth0";
            description = "Choose your network interfaces";
        };
        wireguardInterfaces = lib.mkOption {
            type = lib.types.str;
            default = "wg0";
            example = "wireguard-67";
            description = "Name your wireguard interfaces";
        };
        wireguardAddress = lib.mkOption {
            type = lib.types.str;
            default = "10.88.0.1/24";
            example = "10.88.0.1/24";
            description = "WireGuard interface address (CIDR). WG DNS IP is the host part; peers should set DNS=<IP>.";
        };
        allowedUDPPorts = lib.mkOption {
            type = lib.types.port;
            default = 51820;
            example = 885;
            description = "Allow UDP ports";
        };
        dns = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf lib.types.str);
            default = null;
            defaultText = lib.literalExpression ''["''${wireguardAddress IP}"]'';
            example = ["10.88.0.1"];
            description = ''
                DNS servers advertised to WireGuard peers. When null (default) uses the
                WireGuard gateway IP (host part of wireguardAddress, e.g. 10.88.0.1).
                When Pi-hole is enabled this IP hits Pi-hole FTL (filtered); otherwise it
                hits the local dnsmasq forwarding to 1.1.1.1. Set explicitly if you need
                split DNS or custom address.
            '';
        };
        usePiholeDns = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
                When true and shellix.server.pihole.enable is set, disable the local
                dnsmasq on wg0 and let Pi-hole FTL answer WG DNS queries directly on
                WG_IP:53 (listeningMode=LOCAL covers 10.88.0.0/24). Set false to
                keep dnsmasq even with Pi-hole (not recommended — port 53 conflict).
            '';
        };
        peers = lib.mkOption {
            type = lib.types.listOf (
                lib.types.submodule {
                    options = {
                        publicKey = lib.mkOption {
                            type = lib.types.str;
                            description = "Public key of the peer";
                        };
                        allowedIPs = lib.mkOption {
                            type = lib.types.listOf lib.types.str;
                            description = "List of IPs assigned to this peer";
                        };
                    };
                }
            );
            default = [];
            description = "List of allowed peers";
        };
    };

    config = lib.mkIf cfg.enable {
        # Hint for peer generation: expose effective DNS; tooling/clients should use this.
        # Peers' WireGuard `DNS = 10.88.0.1` will hit Pi-hole when enabled, else dnsmasq.
        warnings =
            lib.optional (piholeEnabled && !cfg.usePiholeDns)
            "shellix.server.wireguard.usePiholeDns=false while pihole is enabled: dnsmasq and Pi-hole both want :53 — expect bind conflicts.";

        # Expose effective DNS for downstream generators / debugging via warnings or trace
        # (not a NixOS option, but keep as passthrough for `nix eval` inspection)
        # effectiveDns is available as cfg.dns ?: [wgIp]; documented here.

        boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = 1;
            "net.ipv4.conf.all.forwarding" = lib.mkOverride 98 true;
            "net.ipv4.conf.default.forwarding" = lib.mkOverride 98 true;
        };

        # DNS for WG — mutually exclusive backends. Pi-hole wins when enabled+usePiholeDns.
        # We use lib.mkIf (not mkForce) so pihole's `mkForce false` on dnsmasq doesn't need fighting;
        # we simply don't define dnsmasq when Pi-hole will serve WG.
        services.dnsmasq = lib.mkIf (!piholeEnabled || !cfg.usePiholeDns) {
            enable = true;
            settings = {
                interface = cfg.wireguardInterfaces;
                bind-interfaces = true;
                listen-address = "127.0.0.1,${wgAddressIP}";
                no-resolv = true;
                server = ["1.1.1.1"];
            };
        };

        networking = {
            nat = {
                enable = true;
                enableIPv6 = lib.mkForce false;
                externalInterface = cfg.externalInterfaces;
                internalInterfaces = [cfg.wireguardInterfaces];
            };
            firewall = {
                allowedTCPPorts = [53];
                allowedUDPPorts = [
                    53
                    cfg.allowedUDPPorts
                ];
                # Explicit per-interface allow for WG DNS — guarantees WG peers can
                # reach Pi-hole (when enabled) or dnsmasq (fallback) on wg interface.
                interfaces.${cfg.wireguardInterfaces} = {
                    allowedTCPPorts = [53];
                    allowedUDPPorts = [53];
                };
            };

            wg-quick.interfaces = {
                ${cfg.wireguardInterfaces} = {
                    address = [cfg.wireguardAddress];
                    listenPort = cfg.allowedUDPPorts;
                    privateKeyFile = cfg.pathPrivateKeyFile;

                    postUp = ''
                        ${pkgs-stable.iptables}/bin/iptables -A FORWARD -i ${cfg.wireguardInterfaces} -j ACCEPT
                        ${pkgs-stable.iptables}/bin/iptables -t nat -A POSTROUTING -s ${wgSubnet} -o ${cfg.externalInterfaces} -j MASQUERADE
                    '';

                    preDown = ''
                        ${pkgs-stable.iptables}/bin/iptables -D FORWARD -i ${cfg.wireguardInterfaces} -j ACCEPT
                        ${pkgs-stable.iptables}/bin/iptables -t nat -D POSTROUTING -s ${wgSubnet} -o ${cfg.externalInterfaces} -j MASQUERADE
                    '';

                    inherit (cfg) peers;
                };
            };
        };
    };
}
