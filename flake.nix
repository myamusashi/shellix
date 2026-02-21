{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.11";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        sops-nix.url = "github:Mic92/sops-nix";

        chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
        nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

        hyprland = {
            url = "github:hyprwm/Hyprland?submodules=1";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hy3 = {
            url = "github:outfoxxed/hy3";
            inputs.hyprland.follows = "hyprland";
        };

        hypr-dynamic-cursors = {
            url = "github:VirtCode/hypr-dynamic-cursors";
            inputs.hyprland.follows = "hyprland";
        };

        Hyprspace = {
            url = "github:myamusashi/Hyprspace";
            inputs.hyprland.follows = "hyprland";
        };

        hyprland-plugins = {
            url = "github:hyprwm/hyprland-plugins";
            inputs.hyprland.follows = "hyprland";
        };

        hyprlock = {
            url = "github:hyprwm/hyprlock";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hypridle = {
            url = "github:hyprwm/hypridle";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprsunset = {
            url = "github:hyprwm/hyprsunset";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprqt6engine = {
            url = "github:hyprwm/hyprqt6engine";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprtoolkit = {
            url = "github:hyprwm/hyprtoolkit";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprlang = {
            url = "github:hyprwm/hyprlang";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprpicker = {
            url = "github:hyprwm/hyprpicker";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprpwcenter = {
            url = "github:hyprwm/hyprpwcenter";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprwire = {
            url = "github:hyprwm/hyprwire";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        antigravity-flakes = {
            url = "github:jacopone/antigravity-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprpanel = {
            url = "github:Jas-SinghFSU/HyprPanel";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        caelestia-shell = {
            url = "github:caelestia-dots/shell";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        caelestia-cli = {
            url = "github:caelestia-dots/cli";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        quickshell = {
            url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        walker = {
            url = "github:abenz1267/walker";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        vermilion = {
            url = "github:vaxerski/Vermilion";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        kwin-effects-forceblur = {
            url = "github:taj-ny/kwin-effects-forceblur";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        winapps = {
            url = "github:winapps-org/winapps";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        vicinae = {
            url = "github:vicinaehq/vicinae";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        mangowc = {
            url = "github:DreamMaoMao/mangowc";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        shell = {
            url = "git+https://git.myamusashi.space/myamusashi/shell";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        m3shapes = {
            url = "github:myamusashi/m3shapes";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        qtengine = {
            url = "github:kossLAN/qtengine";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
        flox.url = "github:flox/flox/v1.7.4";
        spicetify-nix.url = "github:Gerg-L/spicetify-nix";
        matugen.url = "github:/InioX/Matugen/v2.4.1";
        nixgl.url = "github:nix-community/nixGL";
    };

    outputs = inputs: let
        lib = import ./lib {inherit inputs;};
        inherit (lib) mkHost mkHome mkPkgs forAllSystems;
    in {
        nixosConfigurations = {
            nixos = mkHost {
                hostname = "myamusashi";
                username = "myamusashi";
                extraModules = [
                    inputs.chaotic.nixosModules.default
                ];
            };

            waltz = mkHost {
                hostname = "waltz";
                username = null;
            };
        };

        homeConfigurations = {
            "myamusashi" = mkHome {
                username = "myamusashi";
                hostname = "myamusashi";
            };
        };

        devShells = forAllSystems (system: let
            pkgs = mkPkgs {inherit system;};
        in {
            default = pkgs.mkShell {
                buildInputs = with pkgs; [
                    alejandra
                    nil
                    git
                    statix
                    nix-diff
                    nixd
                ];

                shellHook = ''
                    echo "NixOS configuration development environment"
                '';
            };
        });
    };
}
