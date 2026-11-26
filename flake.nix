{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/release-26.05";
        nixos-hardware = {
            url = "github:NixOS/nixos-hardware";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

        flake-parts = {
            url = "github:hercules-ci/flake-parts";
            inputs.nixpkgs-lib.follows = "nixpkgs";
        };

        import-tree.url = "github:vic/import-tree";

        treefmt-nix = {
            url = "github:numtide/treefmt-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

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
            url = "github:hyprwm/Hyprland?rev=f3e076844484255b77629acc5c75379817c405a8";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        xdg-desktop-portal-hyprland = {
            url = "github:hyprwm/xdg-desktop-portal-hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hypr-dynamic-cursors = {
            url = "github:VirtCode/hypr-dynamic-cursors";
            inputs = {
                hyprland.follows = "hyprland";
                nixpkgs.follows = "nixpkgs";
            };
        };

        # hypr-scroll-overview = {
        #     url = "github:yayuuu/hyprland-scroll-overview/new-release";
        #     inputs = {
        #         hyprland.follows = "hyprland";
        #         nixpkgs.follows = "nixpkgs";
        #         flake-parts.follows = "flake-parts";
        #     };
        # };

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

        areofyl-fetch = {
            url = "github:areofyl/fetch";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        apple-fonts = {
            url = "github:Lyndeno/apple-fonts.nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        microvm = {
            url = "github:microvm-nix/microvm.nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nix-cachyos-kernel = {
            url = "github:xddxdd/nix-cachyos-kernel/release";
            inputs.flake-parts.follows = "flake-parts";
        };
    };

    outputs = inputs:
        inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
