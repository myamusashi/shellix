{
    config,
    pkgs,
    lib,
    ...
}: let
    cfg = config.shellix.services.clipse;
    clipsePkg = pkgs.callPackage ./clipse-pkg.nix {
        enableWayland = true;
        enableX11 = false;
    };
    configJson = builtins.toJSON {
        historySize = 500;
        allowDuplicates = false;
        theme = "custom";
        keyBindings = {
            "choose" = "enter";
            "clearSelected" = "S";
            "down" = "down";
            "end" = "end";
            "filter" = "/";
            "home" = "home";
            "more" = "?";
            "nextPage" = "right";
            "prevPage" = "left";
            "preview" = "t";
            "quit" = "q";
            "remove" = "x";
            "selectDown" = "ctrl+down";
            "selectSingle" = "s";
            "selectUp" = "ctrl+up";
            "togglePin" = "p";
            "togglePinned" = "tab";
            "up" = "up";
            "yankFilter" = "ctrl+s";
        };
        imageDisplay = {
            type = "kitty";
        };
    };
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [clipsePkg];

        # Write the config JSON for the user
        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/clipse 0755 myamusashi users - -"
            "L+ %h/.config/clipse/config.json - - - - ${pkgs.writeText "clipse-config" configJson}"
        ];

        systemd.user.services.clipse = {
            Unit = {
                Description = "Clipboard history listener";
                After = ["graphical-session.target"];
            };
            Service = {
                Type = "simple";
                ExecStart = "${clipsePkg}/bin/clipse -listen";
                Restart = "on-failure";
                Slice = "app-graphical.slice";
            };
            Install = {
                WantedBy = ["graphical-session.target"];
            };
        };
    };
}
