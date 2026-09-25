{inputs, ...}: {
    imports = [
        inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        extraSpecialArgs = {inherit inputs;};

        users.myamusashi = {
            imports = [
                ./zen-browser.nix
            ];
            home = {
                stateVersion = "24.11";
                sessionPath = ["/etc/profiles/per-user/myamusashi/bin"];
            };
        };
    };
}
