flakeParts: let
    flakeConfig = flakeParts.config;
in {
    flake.modules.nixos.forgejo = {config, ...}: {
        key = "shellix.nixos.forgejo";

        imports = [
            flakeConfig.flake.modules.nixos.database
            flakeConfig.flake.modules.nixos.servicePorts
        ];

        services.forgejo = {
            enable = true;
            database.type = "postgres";
            lfs.enable = true;
            settings = {
                server = {
                    PROTOCOL = "http+unix";
                    DOMAIN = "git.myamusashi.cc";
                    ROOT_URL = "https://git.myamusashi.cc";
                    HTTP_ADDR = "/run/forgejo/forgejo.sock";
                    HTTP_PORT = config.shellix.ports.forgejo;
                    SSH_DOMAIN = "git.myamusashi.cc";
                };
                actions = {
                    ENABLED = true;
                    DEFAULT_ACTIONS_URL = "github";
                };
                session = {
                    COOKIE_SECURE = true;
                };
                security = {
                    ALLOWED_DOMAINS = "github.com,*.github.com,raw.githubusercontent.com,objects.githubusercontent.com";
                };
            };
        };
    };
}
