{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/release-26.05";
        flake-parts.url = "github:hercules-ci/flake-parts";
        myamusashi-pkgs.url = "github:myamusashi/nix-myamusashi-packages";

        lightauth = {
            url = "git+https://git.myamusashi.cc/myamusashi/lightauth";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland = {
            url = "github:hyprwm/Hyprland?rev=70ec30e71656bce5e1af3364129421a4386a69e1";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        xdg-desktop-portal-hyprland = {
            url = "github:hyprwm/xdg-desktop-portal-hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Hyprland plugins
        hypr-dynamic-cursors = {
            url = "github:VirtCode/hypr-dynamic-cursors";
            inputs.hyprland.follows = "hyprland";
        };

        hypr-scroll-overview = {
            url = "github:yayuuu/hyprland-scroll-overview/new-release";
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

        hyprpicker = {
            url = "github:hyprwm/hyprpicker";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs = {
                nixpkgs.follows = "nixpkgs";
                home-manager.follows = "home-manager";
            };
        };

        shell = {
            url = "git+https://git.myamusashi.cc/myamusashi/vast-shell";
            inputs.nixpkgs.follows = "nixpkgs";
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

        bootvine = {
            url = "git+https://codeberg.org/wvhulle/bootvine";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        areofyl-fetch.url = "github:areofyl/fetch";
        apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
        sops-nix.url = "github:Mic92/sops-nix";
        nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
        spicetify-nix.url = "github:Gerg-L/spicetify-nix";
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
