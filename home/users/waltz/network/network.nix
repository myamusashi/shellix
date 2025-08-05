{config, ...}: {
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    20
    21
    22
  ];
  networking.firewall.allowedUDPPorts = [];

  networking.extraHosts = ''
    192.168.18.14 myamusashi.com
    127.0.0.2 mail.myamusashi.com
    127.0.0.2:9010 cloud.myamusashi.com
    127.0.0.2:9000 pma.myamusashi.com
    127.0.0.2:4032 dash.myamusashi.com
    127.0.0.2:${toString config.services.vaultwarden.config.ROCKET_PORT} vault.myamusashi.com
  '';
  networking.firewall.enable = true;
  networking.networkmanager.enable = true;
}
