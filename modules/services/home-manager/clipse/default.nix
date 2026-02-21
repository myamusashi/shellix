{
    config,
    pkgs,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.services.home-manager.clipse.enable {
        services.clipse = {
            enable = true;
            package = pkgs.callPackage ./clipse.nix {
                enableWayland = true;
                enableX11 = false;
            };
            historySize = 500;
            allowDuplicates = false;
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
    };
}
