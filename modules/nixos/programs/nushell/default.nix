{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.nushell;

    envNu = pkgs.writeText "env.nu" (
        (builtins.readFile ./env.nu)
        + ''
            # ---- user env (loaded last so it overrides) ----
            let user_env = ($env.HOME | path join ".config" "nushell" "env.nu")
            if ($user_env | path exists) {
                source $user_env
            }
        ''
    );

    configNu = pkgs.writeText "config.nu" (
        (builtins.readFile ./config.nu)
        + ''
            # ---- user config (loaded last so it overrides) ----
            let user_config = ($env.HOME | path join ".config" "nushell" "config.nu")
            if ($user_config | path exists) {
                source $user_config
            }
        ''
    );
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.nushell];

        environment.etc = {
            "nushell/env.nu".source = "${envNu}";
            "nushell/config.nu".source = "${configNu}";
        };

        environment.sessionVariables = {
            NU_ENV_FILE = "/etc/nushell/env.nu";
            NU_CONFIG_FILE = "/etc/nushell/config.nu";
        };

        users.users.myamusashi.shell = lib.mkIf cfg.setAsDefaultShell pkgs.nushell;
    };
}
