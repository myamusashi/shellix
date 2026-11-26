{
    flake.modules.nixos.resolver = {
        key = "shellix.nixos.resolver";

        services.resolved = {
            enable = true;
            settings.Resolve = {
                Cache = true;
                # Pi-hole serves plain DNS :53 with dnssec=false; strict DoT/DNSSEC hangs WireGuard DNS.
                DNSOverTLS = "opportunistic";
                DNSSEC = "allow-downgrade";
                DNSStubListener = true;
                ResolveUnicastSingleLabel = true;
                Domains = [
                    "~."
                    "home.myamusashi.dev"
                    "warp-svc"
                ];
            };
        };
    };
}
