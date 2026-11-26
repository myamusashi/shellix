{
    flake.modules.nixos.myamusashiNetworking = {
        key = "shellix.nixos.myamusashiNetworking";

        networking = {
            enableIPv6 = true;
            hostName = "myamusashi";

            networkmanager = {
                enable = true;
                dns = "systemd-resolved";
                ensureProfiles.profiles = {
                    enp0s31f6 = {
                        connection = {
                            id = "enp0s31f6";
                            type = "ethernet";
                            interface-name = "enp0s31f6";
                            autoconnect = true;
                        };
                        ipv4 = {
                            method = "manual";
                            gateway = "192.168.18.1";
                            address1 = "192.168.18.4/28";
                            dns = "192.168.18.14";
                        };
                        ipv6.method = "auto";
                    };
                    myamusashi = {
                        connection = {
                            id = "myamusashi";
                            type = "vlan";
                            interface-name = "myamusashi";
                            autoconnect = true;
                        };
                        vlan = {
                            id = 2;
                            parent = "enp0s31f6";
                        };
                        ipv4 = {
                            method = "manual";
                            address1 = "10.10.10.1/24";
                        };
                        ipv6.method = "link-local";
                    };
                };
            };

            nameservers = [
                "192.168.18.14"
            ];

            extraHosts = ''
                127.0.0.1 pmo.com
                127.0.0.1:9000 pma.myamusashi.com
            '';

            firewall = {
                enable = true;
                interfaces."enp0s31f6".allowedTCPPorts = [
                    22
                    80
                    443
                ];
                interfaces."wlp3s0" = {};
            };

            wg-quick.interfaces.wg0 = {
                address = ["10.88.0.3/32"];
                # Pi-hole BIND mode on waltz answers on 192.168.18.14:53.
                dns = ["192.168.18.14"];
                privateKeyFile = "/etc/wireguard-keys/private.key";
                peers = [
                    {
                        publicKey = "IzirsljupeFXLusg6CooDzjSfc/xGVehBuJetADkaEU=";
                        allowedIPs = ["0.0.0.0/0"];
                        endpoint = "192.168.18.14:51820";
                    }
                ];
            };
        };
    };
}
