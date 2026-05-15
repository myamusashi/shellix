{
    lib,
    config,
    pkgs-stable,
    ...
}: {
    config = lib.mkIf config.shellix.services.server.forgejo.enable {
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
                    HTTP_PORT = 3000;
                    SSH_DOMAIN = "git.myamusashi.cc";
                };
                actions = {
                    ENABLED = true;
                    DEFAULT_ACTIONS_URL = "github";
                };
                session = {
                    COOKIE_SECURE = true;
                };
                "markup.jupyter" = {
                    ENABLED = true;
                    FILE_EXTENSIONS = ".ipynb";
                    RENDER_COMMAND = "${pkgs-stable.python312Packages.nbconvert}/bin/jupyter-nbconvert --to html --stdout";
                    IS_INPUT_FILE = true;
                };
                security = {
                    ALLOWED_DOMAINS = "github.com,*.github.com,raw.githubusercontent.com,objects.githubusercontent.com";
                };
            };
        };
    };
}
