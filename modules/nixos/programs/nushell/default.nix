{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.nushell;

    envNu = pkgs.writeText "env.nu" (
        builtins.readFile ./env.nu
        + (lib.optionalString (cfg.username == "myamusashi") ''
            $env.GITHUB_TOKEN = (cat ${config.sops.secrets.github_token.path})
            $env.FIRECRAWL_API_KEY = (cat ${config.sops.secrets.firecrawl_api.path})
            $env.MINIMAX_API_KEY = (cat ${config.sops.secrets.commandcode_api.path})
        '')
    );

    configNu = pkgs.writeText "config.nu" (builtins.readFile ./config.nu);
in {
    config = lib.mkIf cfg.enable {
        environment.shells = [pkgs.nushell];
        environment.systemPackages = [pkgs.nushell pkgs.zoxide pkgs.carapace];

        systemd.user.tmpfiles.rules = [
            "d %h/.config/nushell 0755 myamusashi users - -"
            "L+ %h/.config/nushell/env.nu - - - - ${envNu}"
            "L+ %h/.config/nushell/config.nu - - - - ${configNu}"
        ];

        users.users."${cfg.username}".shell = lib.mkIf cfg.setAsDefaultShell pkgs.nushell;
    };
}
