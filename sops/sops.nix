{
    sops = {
        defaultSopsFile = ./secrets.json;
        defaultSopsFormat = "json";

        secrets = {
            nix-serve_secrets.mode = "0440";
            ocis_admin_pass.mode = "0440";
            grafana_secret_key.mode = "0440";
            smtp_app_password.mode = "0440";
            user1-mail.mode = "0440";

            github_token = {
                path = "/home/myamusashi/.config/sops-nix/secrets/github_token";
            };

            weatherapi = {
                path = "/home/myamusashi/.config/sops-nix/secrets/weatherapi";
            };
            latitude = {
                path = "/home/myamusashi/.config/sops-nix/secrets/latitude";
            };
            longitude = {
                path = "/home/myamusashi/.config/sops-nix/secrets/longitude";
            };

            cloudflare_creds = {
                path = "/var/lib/cloudflared/creds";
            };

            forgejo_runner_helium_token = {
                path = "/var/lib/forgejo-runner/token/helium";
            };
            forgejo_runner_pgs_token = {
                path = "/var/lib/forgejo-runner/token/pgs";
            };
            forgejo_runner_vast_token = {
                path = "/var/lib/forgejo-runner/token/vast-shell";
            };
            forgejo_runner_yaziplgs_token = {
                path = "/var/lib/forgejo-runner/token/yaziplgs";
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
        };
    };
}
