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
            description = "WireGuard interface address";
        };
        allowedUDPPorts = lib.mkOption {
            type = lib.types.port;
            default = 51820;
            example = 885;
            description = "Allow UDP ports";
        };
        peers = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
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
            });
            default = [];
            description = "List of allowed peers";
        };
    };

    config = lib.mkIf cfg.enable {
        boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = 1;
            "net.ipv4.conf.all.forwarding" = lib.mkOverride 98 true;
            "net.ipv4.conf.default.forwarding" = lib.mkOverride 98 true;
        };

        services.dnsmasq = {
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
                allowedUDPPorts = [53 cfg.allowedUDPPorts];
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
