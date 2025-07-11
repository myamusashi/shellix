{
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      insertNameservers = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
    };
    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
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
  services.resolved = {
    enable = true;
    dnssec = "true";
    dnsovertls = "true";
  };
}
