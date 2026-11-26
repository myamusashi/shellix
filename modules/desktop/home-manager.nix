flakeParts: let
    flakeConfig = flakeParts.config;
    inherit (flakeParts) inputs;
in {
    flake.modules.nixos.homeManagerMyamusashi = {
        key = "shellix.nixos.homeManagerMyamusashi";

        imports = [
            inputs.home-manager.nixosModules.home-manager
        ];

        home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";

            users.myamusashi = {
                imports = [
                    flakeConfig.flake.modules.homeManager.zenBrowser
                    flakeConfig.flake.modules.homeManager.areofylFetch
                ];
                home = {
                    stateVersion = "24.11";
                    sessionPath = ["/etc/profiles/per-user/myamusashi/bin"];
                };
            };
        };
    };
}
