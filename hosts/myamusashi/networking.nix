{lib, ...}: {
    networking = {
        enableIPv6 = true;
        hostName = "nixos";
        defaultGateway = {
            address = "192.168.18.1";
            interface = "enp0s31f6";
        };
        dhcpcd.enable = false;
        networkmanager = {
            enable = true;
            dns = "systemd-resolved";
            insertNameservers = [
                "1.1.1.1#one.one.one.one"
                "1.0.0.1#one.one.one.one"
                "94.140.14.14" # adGuard
                "94.140.15.15"
            ];
        };
        domain = "home.myamusashi.dev";
        search = ["home.myamusashi.dev"];
        interfaces = {
            enp0s31f6.ipv4.addresses = [
                {
                    address = "192.168.18.2";
                    prefixLength = 28;
                }
            ];
            myamusashi.ipv4.addresses = [
                {
                    address = "10.10.10.1";
                    prefixLength = 24;
                }
            ];
        };
        vlans = {
            myamusashi = {
                id = 2;
                interface = "enp0s31f6";
            };
        };
        nameservers = [
            "192.168.18.4"
            "1.1.1.1#one.one.one.one"
            "1.0.0.1#one.one.one.one"
            "94.140.14.14"
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
        # wg-quick.interfaces = {
        #     wg0 = {
        #         mtu = 1420;
        #         address = lib.mkDefault ["10.88.0.3/32"];
        #         listenPort = 51820;
        #         dns = ["1.1.1.1"];
        #         privateKeyFile = "/etc/wireguard-keys/private.key";
        #         peers = [
        #             {
        #                 publicKey = "IzirsljupeFXLusg6CooDzjSfc/xGVehBuJetADkaEU=";
        #                 allowedIPs = ["0.0.0.0/0"];
        #                 endpoint = "192.168.18.14:51820";
        #             }
        #         ];
        #     };
        # };
    };
}
