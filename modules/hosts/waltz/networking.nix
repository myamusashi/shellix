{
    flake.modules.nixos.waltzNetworking = {lib, ...}: let
        lanAndTunnelTcpPorts = [
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
    in {
        key = "shellix.nixos.waltzNetworking";

        boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkForce 1;

        services.create_ap = {
            enable = true;
            settings = {
                INTERNET_IFACE = "enp1s0";
                PASSPHRASE = "12345678";
                SSID = "nixos waltz";
                WIFI_IFACE = "wlp2s0";
            };
        };

        networking = {
            hostName = "waltz";
            domain = "home.waltz.dev";
            search = ["home.waltz.dev"];

            nftables = {
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

            networkmanager = {
                enable = true;
                dns = "systemd-resolved";
                unmanaged = ["interface-name:wlp2s0"];
                insertNameservers = [
                    "1.1.1.1#one.one.one.one"
                    "1.0.0.1#one.one.one.one"
                    "94.140.14.14"
                    "94.140.15.15"
                ];
            };

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

            vlans.waltz = {
                id = 2;
                interface = "enp1s0";
            };

            nameservers = [
                "1.1.1.1#one.one.one.one"
                "1.0.0.1#one.one.one.one"
                "94.140.14.14"
                "94.140.15.15"
            ];

            defaultGateway = {
                address = "192.168.18.1";
                interface = "enp1s0";
            };

            firewall = {
                enable = true;
                trustedInterfaces = ["wg0"];
                # Pi-hole, WireGuard, and WARP open global ports that would expose services on the AP;
                # clear global lists and scope allowed ports per interface instead.
                allowedTCPPorts = lib.mkForce [];
                allowedUDPPorts = lib.mkForce [];
                interfaces = {
                    wlp2s0 = {
                        allowedTCPPorts = [53];
                        allowedUDPPorts = [
                            53
                            67
                            68
                        ];
                    };
                    enp1s0 = {
                        allowedTCPPorts = lanAndTunnelTcpPorts;
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
                    wg0 = {
                        allowedTCPPorts = lanAndTunnelTcpPorts;
                        allowedUDPPorts = [
                            53
                            5353
                            5432
                            3001
                            3002
                        ];
                    };
                };
            };
        };
    };
}
