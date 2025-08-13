{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.shellix.services.nixos.resolver.enable {
    services.resolved = {
      enable = true;
      dnssec = "true";
      fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      extraConfig = ''
        DNSStubListener=yes
        Cache=yes
        DNSStubListenerExtra=127.0.0.1
      '';
    };
  };
}
