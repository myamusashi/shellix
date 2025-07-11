{config, ...}: {
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    20
    21
    22
  ];
  networking.firewall.allowedUDPPorts = [
  ];

  networking.extraHosts = ''
    192.168.18.14 myamusashi.com
    127.0.0.1 mail.myamusashi.com
    127.0.0.1:9010 cloud.myamusashi.com
    127.0.0.1:9000 pma.myamusashi.com
    127.0.0.1:4032 dash.myamusashi.com
		127.0.0.1:3000 matomo.myamusashi.org
    127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT} vault.myamusashi.com
  '';
  # Or disable the firewall altogether.
  # 25|465|587|110|143|993|995|80|443
  #
  networking.firewall.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
}
