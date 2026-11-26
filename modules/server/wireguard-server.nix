{
    flake.modules.nixos.wireguardServer = {
        config,
        lib,
        pkgs,
        ...
    }: let
        wireguardConfig = config.shellix.wireguard;
        addressParts = lib.splitString "/" wireguardConfig.address;
        addressIp = lib.head addressParts;
        addressPrefix = lib.last addressParts;
        wireguardSubnet = "${lib.concatStringsSep "." (lib.init (lib.splitString "." addressIp))}.0/${addressPrefix}";
        piholeEnabled = config.services.pihole-ftl.enable;
    in {
        key = "shellix.nixos.wireguardServer";

        options.shellix.wireguard = {
            privateKeyFile = lib.mkOption {
                type = lib.types.path;
                example = "/etc/wireguard-keys/private.key";
                description = "Absolute path to the WireGuard private key file.";
            };
            externalInterface = lib.mkOption {
                type = lib.types.str;
                default = "enp1s0";
                example = "eth0";
                description = "External WAN/LAN network interface used for NAT masquerading.";
            };
            interface = lib.mkOption {
                type = lib.types.str;
                default = "wg0";
                description = "WireGuard interface name.";
            };
            address = lib.mkOption {
                type = lib.types.str;
                default = "10.88.0.1/24";
                description = "WireGuard interface IPv4 CIDR address.";
            };
            listenPort = lib.mkOption {
                type = lib.types.port;
                default = 51820;
                description = "WireGuard UDP listen port.";
            };
            usePiholeDns = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Defer port 53 DNS handling to Pi-hole FTL when enabled instead of running local dnsmasq.";
            };
            peers = lib.mkOption {
                type = lib.types.listOf (
                    lib.types.submodule {
                        options = {
                            publicKey = lib.mkOption {
                                type = lib.types.str;
                                description = "Public key of the WireGuard peer.";
                            };
                            allowedIPs = lib.mkOption {
                                type = lib.types.listOf lib.types.str;
                                description = "Allowed IP CIDR prefixes assigned to this peer.";
                            };
                        };
                    }
                );
                default = [];
                description = "List of authorized WireGuard peers.";
            };
        };

        config = {
            warnings =
                lib.optional (piholeEnabled && !wireguardConfig.usePiholeDns)
                "shellix.wireguard.usePiholeDns=false while Pi-hole is enabled: dnsmasq and Pi-hole will conflict on port 53.";

            boot.kernel.sysctl = {
                "net.ipv4.ip_forward" = 1;
                "net.ipv4.conf.all.forwarding" = lib.mkOverride 98 true;
                "net.ipv4.conf.default.forwarding" = lib.mkOverride 98 true;
            };

            services.dnsmasq = lib.mkIf (!piholeEnabled || !wireguardConfig.usePiholeDns) {
                enable = true;
                settings = {
                    inherit (wireguardConfig) interface;
                    bind-interfaces = true;
                    listen-address = "127.0.0.1,${addressIp}";
                    no-resolv = true;
                    server = ["1.1.1.1"];
                };
            };

            networking = {
                nat = {
                    enable = true;
                    enableIPv6 = lib.mkForce false;
                    inherit (wireguardConfig) externalInterface;
                    internalInterfaces = [wireguardConfig.interface];
                };

                firewall = {
                    allowedTCPPorts = [53];
                    allowedUDPPorts = [
                        53
                        wireguardConfig.listenPort
                    ];
                    interfaces.${wireguardConfig.interface} = {
                        allowedTCPPorts = [53];
                        allowedUDPPorts = [53];
                    };
                };

                wg-quick.interfaces.${wireguardConfig.interface} = {
                    address = [wireguardConfig.address];
                    inherit (wireguardConfig) listenPort privateKeyFile peers;

                    postUp = ''
                        ${pkgs.iptables}/bin/iptables -A FORWARD -i ${wireguardConfig.interface} -j ACCEPT
                        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${wireguardSubnet} -o ${wireguardConfig.externalInterface} -j MASQUERADE
                    '';

                    preDown = ''
                        ${pkgs.iptables}/bin/iptables -D FORWARD -i ${wireguardConfig.interface} -j ACCEPT
                        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${wireguardSubnet} -o ${wireguardConfig.externalInterface} -j MASQUERADE
                    '';
                };
            };
        };
    };
}
