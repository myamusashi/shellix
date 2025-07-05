{
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    extraHosts = ''
      127.0.0.1 pmo.com
    '';
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
      ];
      allowedUDPPorts = [
        22
      ];
    };
  };
}
