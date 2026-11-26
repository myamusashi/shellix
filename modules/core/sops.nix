{inputs, ...}: {
    flake.modules.nixos.sopsBase = {
        key = "shellix.nixos.sopsBase";

        imports = [
            inputs.sops-nix.nixosModules.sops
        ];

        sops = {
            defaultSopsFile = ../../sops/secrets.json;
            defaultSopsFormat = "json";
        };
    };
}
