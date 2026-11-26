{
    flake.modules.nixos.gnupg = {
        config,
        pkgs,
        ...
    }: let
        sessionVariables = config.environment.sessionVariables;
        pinentryQtWrapped = pkgs.writeShellScriptBin "pinentry-qt" ''
            export QT_QPA_PLATFORMTHEME="${sessionVariables.QT_QPA_PLATFORMTHEME or "qtengine"}"
            export QT_STYLE_OVERRIDE="${sessionVariables.QT_STYLE_OVERRIDE or ""}"
            exec ${pkgs.pinentry-qt}/bin/pinentry-qt "$@"
        '';
    in {
        key = "shellix.nixos.gnupg";

        programs.gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
            pinentryPackage = pinentryQtWrapped;
        };
    };
}
