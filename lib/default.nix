{inputs, ...}: let
    inherit (inputs.nixpkgs) lib;
in rec {
    supportedSystems = ["x86_64-linux" "aarch64-linux"];

    forAllSystems = lib.genAttrs supportedSystems;

    mkPkgs = {
        system,
        nixpkgs ? inputs.nixpkgs,
        overlays ? [],
    }:
        import nixpkgs {
            inherit system;
            config = {
                allowUnfree = true;
                android_sdk.accept_license = true;
            };
            overlays =
                [
                    (import ../overlays)
                    inputs.hyprpicker.overlays.default
                    inputs.hyprsunset.overlays.default
                    inputs.hypridle.overlays.default
                    inputs.hyprland.overlays.default
                    inputs.nix-cachyos-kernel.overlays.pinned
                    inputs.vicinae.overlays.default
                ]
                ++ overlays;
        };

    mkPkgsStable = {system}:
        import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
            overlays = [
                inputs.nix-cachyos-kernel.overlays.pinned
            ];
        };

    mkHost = {
        hostname,
        system ? "x86_64-linux",
        username ? null,
        homeFile ? "home.nix",
        extraModules ? [],
    }: let
        hmModules = lib.optionals (username != null) [
            inputs.home-manager.nixosModules.home-manager
            {
                home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    backupFileExtension = "hm-backup";
                    extraSpecialArgs = {inherit inputs system;};
                    users.${username} = import ../hosts/${hostname}/${homeFile};
                };
            }
        ];
    in
        inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
                inherit inputs;
                pkgs-stable = mkPkgsStable {inherit system;};
            };
            modules =
                [
                    ../hosts/${hostname}
                    ../sops/sops.nix

                    inputs.sops-nix.nixosModules.sops

                    {
                        nixpkgs.overlays = [
                            (import ../overlays)
                            inputs.hyprland.overlays.default
                            inputs.hyprpicker.overlays.default
                            inputs.hyprsunset.overlays.default
                            inputs.hypridle.overlays.default
                            inputs.nix-cachyos-kernel.overlays.pinned
                        ];
                    }
                ]
                ++ hmModules ++ extraModules;
        };

    mkHome = {
        username,
        hostname,
        system ? "x86_64-linux",
        homeFile ? "home.nix",
    }:
        inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = mkPkgs {inherit system;};
            extraSpecialArgs = {inherit inputs system;};
            modules = [../hosts/${hostname}/${homeFile}];
        };
}
