{inputs, ...}: let
    inherit (inputs.nixpkgs) lib;

    hyprland-ecosystem = [
        inputs.hyprpicker.overlays.default
        inputs.hyprsunset.overlays.default
        inputs.hypridle.overlays.default
        inputs.hyprland.overlays.default
    ];
in rec {
    supportedSystems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = lib.genAttrs supportedSystems;

    shellix-lib = import ./modules.nix {inherit lib;};
    shellix-pkgs = system: import ./pkgs.nix {pkgs = mkPkgs {inherit system;};};

    mkPatchedZenBrowser = system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        src = pkgs.applyPatches {
            name = "zen-browser-flake-patched";
            src = inputs.zen-browser.outPath;
            patches = [
                ../0001-feat-sine-support-configuration-shipped-local-mods.patch
            ];
        };
        flake = import "${src}/flake.nix";
        self =
            inputs.zen-browser
            // {
                outPath = "${src}";
            }
            // flake.outputs {
                inherit self;
                inherit (inputs) nixpkgs home-manager;
            };
    in
        self;

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
                    inputs.nix-cachyos-kernel.overlays.pinned
                ]
                ++ overlays ++ hyprland-ecosystem;
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
        patchedInputs =
            inputs
            // {
                zen-browser = mkPatchedZenBrowser system;
            };
    in
        inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
                inherit shellix-lib;
                inputs = patchedInputs;
                pkgs-stable = mkPkgsStable {inherit system;};
                pkgs-unstable = mkPkgs {inherit system;};
                shellix-pkgs = shellix-pkgs system;
            };
            modules =
                [
                    ../hosts/${hostname}
                    ../sops/sops.nix

                    inputs.sops-nix.nixosModules.sops

                    {
                        nixpkgs.overlays =
                            [
                                (import ../overlays)
                                inputs.nix-cachyos-kernel.overlays.pinned
                            ]
                            ++ hyprland-ecosystem;
                    }
                ]
                ++ extraModules;
        };
}
