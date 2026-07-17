{
    config,
    lib,
    ...
}: let
    domain = "myamusashi.cc";
    hostname = "mail.${domain}";
in {
    config = lib.mkIf config.shellix.server.mail.enable {
        services.stalwart = {
            enable = true;
            stateVersion = "26.05";
            openFirewall = true;

            credentials = {
                cloudflare_api_token = config.sops.secrets.stalwart_cloudflare_token.path;
                brevo_user = config.sops.secrets.stalwart_brevo_user.path;
                brevo_key = config.sops.secrets.stalwart_brevo_key.path;
                admin_password = config.sops.secrets.stalwart_admin_password.path;
            };

            settings = {
                server = {
                    inherit hostname;

                    listener = {
                        smtp = {
                            bind = ["[::]:25"];
                            protocol = "smtp";
                        };
                        submission = {
                            bind = ["[::]:587"];
                            protocol = "smtp";
                        };
                        submissions = {
                            bind = ["[::]:465"];
                            protocol = "smtp";
                            tls.implicit = true;
                        };
                        imaps = {
                            bind = ["[::]:993"];
                            protocol = "imap";
                            tls.implicit = true;
                        };
                        http = {
                            bind = ["[::]:8080"];
                            protocol = "http";
                        };
                    };
                };

                acme."letsencrypt" = {
                    directory = "https://acme-v02.api.letsencrypt.org/directory";
                    challenge = "dns-01";
                    contact = "postmaster@${domain}";
                    domains = [hostname domain];
                    provider = "cloudflare";
                    secret = "%{file:/run/credentials/stalwart.service/cloudflare_api_token}%";
                };

                server.tls = {
                    certificate = "letsencrypt";
                    enable = true;
                };

                resolver = {
                    type = "cloudflare";
                    preserve-intermediates = true;
                    timeout = "5s";
                    attempts = 2;
                };

                lookup.default = {
                    inherit hostname domain;
                };

                authentication.fallback-admin = {
                    user = "admin";
                    secret = "%{file:/run/credentials/stalwart.service/admin_password}%";
                };

                directory.internal.bootstrap = {
                    class = "individual";
                    name = "admin";
                    description = "System Administrator";
                    secret = "%{file:/run/credentials/stalwart.service/admin_password}%";
                    email = ["admin@${domain}"];
                };

                session.auth = {
                    mechanisms = "[plain]";
                    directory = "'internal'";
                };

                session.rcpt.directory = "'internal'";

                queue.strategy.route = "'brevo'";

                route.local."@type" = "Local";

                route.brevo = {
                    "@type" = "Relay";
                    address = "smtp-relay.brevo.com";
                    port = 587;
                    protocol = "smtp";
                    implicitTls = false;
                    allowInvalidCerts = false;
                    authUsername = "%{file:/run/credentials/stalwart.service/brevo_user}%";
                    authSecret = {
                        "@type" = "File";
                        path = "/run/credentials/stalwart.service/brevo_key";
                    };
                };
            };
        };

        sops.secrets = {
            stalwart_cloudflare_token = {};
            stalwart_brevo_user = {};
            stalwart_brevo_key = {};
            stalwart_admin_password = {};
        };

        shellix.server.cloudflared.ingress."webmail.${domain}" = "http://localhost:8080";
    };
}
