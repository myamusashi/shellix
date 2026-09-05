{lib, ...}: {
    networking = {
        enableIPv6 = true;
        hostName = "nixos";
        networkmanager = {
            enable = true;
            dns = "systemd-resolved";
            ensureProfiles.profiles = {
                # caveat: even if you set permissions to "user:myamusashi:"
                # NetworkManager will have read/write access to these files
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
                    ipv6 = {
                        method = "auto";
                    };
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
                    ipv6 = {
                        method = "link-local";
                    };
                };
            };
        };
        domain = "home.myamusashi.dev";
        search = ["home.myamusashi.dev"];
        nameservers = [
            "192.168.18.14" # pi-hole
            "1.1.1.1#one.one.one.one"
            "1.0.0.1#one.one.one.one"
            "94.140.14.14" # adGuard
            "94.140.15.15"
        ];
        extraHosts = ''
            127.0.0.1 pmo.com
            127.0.0.1:9000 pma.myamusashi.com
        '';
        firewall = {
            enable = true;
            allowedTCPPorts = [
                22
                80
                443
            ];
            allowedUDPPorts = [
                22
                51820
            ];
            allowedUDPPortRanges = [
                {
                    from = 1714;
                    to = 1764;
                }
            ];
            allowedTCPPortRanges = [
                {
                    from = 1714;
                    to = 1764;
                }
            ];
        };
        wg-quick.interfaces = {
            wg0 = {
                address = lib.mkDefault ["10.88.0.3/32"];
                listenPort = 51820;
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
