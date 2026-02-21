{
    config,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.services.nixos.resolver.enable {
        services.resolved = {
            enable = true;
            settings.Resolve = {
                Cache = true;
                DNSOverTLS = true;
                DNSSEC = true;
                DNSStubListener = true;
                FallbackDNS = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
            };
        };
    };
}
