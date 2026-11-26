{inputs, ...}: {
    flake.modules.nixos.lightauth = {
        config,
        pkgs,
        ...
    }: let
        lightauthPackage = inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.lightauth;
    in {
        key = "shellix.nixos.lightauth";

        imports = [
            inputs.lightauth.nixosModules.lightauth
        ];

        services.lightauth = {
            enable = true;
            package = lightauthPackage;
            configFile = config.sops.secrets.lightauth_configs.path;
        };

        environment.systemPackages = [lightauthPackage];
    };
}
