{inputs, ...}: {
    flake.modules.nixos.nixSettings = {
        key = "shellix.nixos.nixSettings";

        imports = [
            inputs.determinate.nixosModules.default
        ];

        nix = {
            enable = true;
            settings = {
                eval-cores = 0;
                lazy-trees = true;
                experimental-features = [
                    "nix-command"
                    "flakes"
                    "parallel-eval"
                ];
                substituters = [
                    "https://install.determinate.systems"
                    "https://myamusashi.cachix.org"
                    "https://cache.nixos.org"
                    "https://nix-community.cachix.org"
                    "https://ezkea.cachix.org"
                    "https://hyprland.cachix.org"
                    "https://cache.xinux.uz"
                    "https://cache.lantian.pub/lantian"
                ];
                trusted-public-keys = [
                    "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
                    "myamusashi.cachix.org-1:ra4PbY6yqM1pSvkGqJ78CZse3WWgjk4rOXBMtjD9YrY="
                    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                    "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
                    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                    "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
                    "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
                ];
            };
        };
    };
}
