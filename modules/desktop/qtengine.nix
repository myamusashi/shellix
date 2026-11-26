{inputs, ...}: {
    flake.modules.nixos.qtengine = {
        key = "shellix.nixos.qtengine";

        imports = [
            inputs.qtengine.nixosModules.default
        ];

        programs.qtengine = {
            enable = true;

            config = {
                theme = {
                    colorScheme = "/home/myamusashi/.local/share/color-schemes/Shellix.colors";
                    iconTheme = "MoreWaita";
                    style = "darkly";

                    font = {
                        family = "SF Pro";
                        size = 11;
                        weight = -1;
                    };

                    fontFixed = {
                        family = "Maple Mono NF";
                        size = 11;
                        weight = -1;
                    };
                };

                misc = {
                    singleClickActivate = false;
                    menusHaveIcons = true;
                    shortcutsForContextMenus = true;
                };
            };
        };
    };
}
