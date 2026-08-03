{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/release-26.05";
        flake-parts.url = "github:hercules-ci/flake-parts";
        myamusashi-pkgs.url = "github:myamusashi/nix-myamusashi-packages";

        aquamarine = {
            url = "github:hyprwm/aquamarine";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland = {
            url = "github:hyprwm/Hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprutils = {
            url = "github:hyprwm/hyprutils";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprcursor = {
            url = "github:hyprwm/hyprcursor";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprgraphics = {
            url = "github:hyprwm/hyprgraphics";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland-protocols = {
            url = "github:hyprwm/hyprland-protocols";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland-guiutils = {
            url = "github:hyprwm/hyprland-guiutils";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprlang = {
            url = "github:hyprwm/hyprlang";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprwayland-scanner = {
            url = "github:hyprwm/hyprland-guiutils";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprwire = {
            url = "github:hyprwm/hyprwire";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Hyprland plugins
        hypr-dynamic-cursors = {
            url = "github:myamusashi/hypr-dynamic-cursors";
            inputs.hyprland.follows = "hyprland";
        };

        hypr-scroll-overview = {
            url = "github:myamusashi/hyprland-scroll-overview";
            inputs.hyprland.follows = "hyprland";
        };

        # End

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

        hyprpicker = {
            url = "github:hyprwm/hyprpicker";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprpwcenter = {
            url = "github:hyprwm/hyprpwcenter";
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

        quickshell = {
            url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        kwin-effects-forceblur = {
            url = "github:taj-ny/kwin-effects-forceblur";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        shell = {
            url = "git+https://git.myamusashi.cc/myamusashi/vast-shell";
            inputs = {
                nixpkgs.follows = "nixpkgs";
                quickshell.follows = "quickshell";
            };
        };

        qtengine = {
            url = "github:kossLAN/qtengine";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        helium = {
            url = "git+https://git.myamusashi.cc/myamusashi/helium-flakes.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        yazi-plugins-flakes = {
            url = "git+https://git.myamusashi.cc/myamusashi/yazi_plugins-flake.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        aerothemeplasma-nix = {
            url = "github:nyakase/aerothemeplasma-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        sesame = {
            url = "git+https://git.myamusashi.cc/myamusashi/sesame.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
        sops-nix.url = "github:Mic92/sops-nix";
        nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
        spicetify-nix.url = "github:Gerg-L/spicetify-nix";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs @ {flake-parts, ...}:
        flake-parts.lib.mkFlake {inherit inputs;} {
            systems = ["x86_64-linux" "aarch64-linux"];

            flake = let
                lib = import ./lib {inherit inputs;};
                inherit (lib) mkHost;
            in {
                nixosConfigurations = {
                    nixos = mkHost {
                        hostname = "myamusashi";
                        username = "myamusashi";
                    };

                    waltz = mkHost {
                        hostname = "waltz";
                        username = null;
                    };
                };
            };

            perSystem = {pkgs, ...}: {
                formatter = pkgs.alejandra;

                devShells.default = pkgs.mkShell {
                    buildInputs = with pkgs; [
                        alejandra
                        nil
                        statix
                        nixd
                    ];
                    shellHook = ''
                        echo "NixOS configuration development environment"
                    '';
                };
            };
        };
}
