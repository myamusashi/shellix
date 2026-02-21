{
    sops = {
        defaultSopsFile = ./secrets.json;
        defaultSopsFormat = "json";

        secrets = {
            cloudflare_creds.mode = "0440";
            nix-serve_secrets.mode = "0440";
            nextcloud_admin_pass.mode = "0440";

            weatherapi = {
                path = "/home/myamusashi/.config/sops-nix/secrets/weatherapi";
            };
            latitude = {
                path = "/home/myamusashi/.config/sops-nix/secrets/latitude";
            };
            longitude = {
                path = "/home/myamusashi/.config/sops-nix/secrets/longitude";
            };

            myamusashi-password = {
                path = "/var/lib/myamusashi/pass";
            };
            waltz-password = {
                path = "/var/lib/waltz/pass";
            };
            myamusashi-borg = {
                path = "/var/lib/myamusashi/borg-secret";
            };
            waltz-borg = {
                path = "/var/lib/waltz/borg-secret";
            };

            user1-mail = {
                mode = "0440";
            };
        };
    };
}
