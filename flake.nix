{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.05";
    sops-nix.url = "github:Mic92/sops-nix";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:myamusashi/zen-twilight-flake";
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

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    matugen.url = "github:/InioX/Matugen/v2.4.1";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    chaotic,
    nixgl,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
      overlays = [(import ./overlays/default.nix)];
    };
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.hyprpicker.overlays.default
        inputs.hyprsunset.overlays.default
        inputs.hypridle.overlays.default
        inputs.hyprland.overlays.default
        nixgl.overlay
        inputs.neovim-nightly-overlay.overlays.default
      ];
    };
  in {
    nixosConfigurations = {
      waltz = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./sops/sops.nix
          ./hosts/waltz/configuration.nix
          chaotic.nixosModules.nyx-cache
          chaotic.nixosModules.nyx-overlay
          chaotic.nixosModules.nyx-registry
        ];
        specialArgs = {
          inherit inputs;
          inherit pkgs-stable;
        };
      };

      # NOTE: nixos dan myamusashi sama saja
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          chaotic.nixosModules.default
          ./sops/sops.nix
          ./hosts/myamusashi/configuration.nix
        ];
        specialArgs = {
          inherit inputs;
          inherit pkgs-stable;
        };
      };
    };

    homeConfigurations = {
      "myamusashi" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit system;
          inherit inputs;
        };

        modules = [
          ./hosts/myamusashi/home.nix
        ];
      };
      "waltz" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs-stable;

        extraSpecialArgs = {
          inherit system;
          inherit inputs;
        };

        modules = [
          ./hosts/waltz/home.nix
        ];
      };
    };
  };
}
