{
    config,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.services.resolver.enable {
        services.resolved = {
            enable = true;
            settings.Resolve = {
                Cache = true;
                # Pi-hole (192.168.18.14, 10.88.0.1 via WG) serves plain DNS :53 only
                # with dnssec=false — strict DoT/DNSSEC hangs WG DNS (see 2026-09-06).
                # opportunistic/allow-downgrade: plain to Pi-hole, upgrade to 1.1.1.1 when possible.
                DNSOverTLS = "opportunistic";
                DNSSEC = "allow-downgrade";
                DNSStubListener = true;
                FallbackDNS = [
                    "1.1.1.1#one.one.one.one"
                    "1.0.0.1#one.one.one.one"
                ];
            };
        };
    };
}
