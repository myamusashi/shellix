{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.05";
    sops-nix.url = "github:Mic92/sops-nix";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland?submodules=1";
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

    winapps = {
      url = "github:winapps-org/winapps";
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

    hyprwire = {
      url = "github:hyprwm/hyprwire";
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

  outputs = {
    self,
    nix-cachyos-kernel,
    nixpkgs,
    nixpkgs-stable,
    chaotic,
    nixgl,
    home-manager,
    sops-nix,
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
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.vicinae.overlays.default
        (final: prev: {
          vicinae = prev.vicinae.overrideAttrs (oldAttrs: {
            cmakeFlags = [
              "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
            ];
          });
          grpc-tools = prev.grpc-tools.overrideAttrs (oldAttrs: {
            cmakeFlags = [
              "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
            ];
          });
          cmark-gfm = prev.cmark-gfm.overrideAttrs (oldAttrs: {
            cmakeFlags = [
              "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
            ];
          });
        })
      ];
    };
  in {
    nixosConfigurations = {
      waltz = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          sops-nix.nixosModules.sops
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

      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          chaotic.nixosModules.default
          ./sops/sops.nix
          ./hosts/myamusashi/configuration.nix

          {
            nixpkgs.overlays = [
              nix-cachyos-kernel.overlays.pinned
            ];
          }
        ];
        specialArgs = {
          inherit inputs;
          inherit pkgs-stable;
        };
      };
    };

    homeConfigurations = {
      home-manager.sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
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
    };

    devShells.${system}.default = pkgs.mkShell {
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
  };
}
