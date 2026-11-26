{
    flake.modules.nixos.waltzUsers = {
        key = "shellix.nixos.waltzUsers";

        users = {
            users = {
                waltz = {
                    isNormalUser = true;
                    description = "waltz";
                    extraGroups = [
                        "networkmanager"
                        "wheel"
                        "vsftpd"
                        "microvm"
                    ];
                };
                cloudflared = {
                    isSystemUser = true;
                    group = "cloudflared";
                    description = "Cloudflare Tunnel service user";
                    extraGroups = ["forgejo"];
                };
                ocis = {
                    isSystemUser = true;
                    group = "ocis";
                };
                nginx = {
                    isSystemUser = true;
                    group = "nginx";
                };
                netdata = {
                    isSystemUser = true;
                    group = "netdata";
                };
                runner = {
                    isNormalUser = true;
                    group = "runner";
                    extraGroups = ["forgejo"];
                };
            };

            groups = {
                cloudflared = {};
                ocis = {};
                netdata = {};
                nginx = {};
                runner = {};
            };
        };
    };
}
