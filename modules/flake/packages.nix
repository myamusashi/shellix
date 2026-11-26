{
    perSystem = {pkgs, ...}: {
        packages = {
            app2unit = pkgs.callPackage ../../packages/app2unit.nix {};
            future-cursor = pkgs.callPackage ../../packages/future-cursor.nix {};
            future-cyan-hyprcursor = pkgs.callPackage ../../packages/future-cyan-hyprcursor.nix {};
            google-sans-flex = pkgs.callPackage ../../packages/google-sans-flex.nix {};
            mornye = pkgs.callPackage ../../packages/mornye.nix {};
            switzer-font = pkgs.callPackage ../../packages/switzer-font.nix {};
            zcode = pkgs.callPackage ../../packages/zcode.nix {};
            zcode-bridge = pkgs.callPackage ../../packages/zcode-bridge.nix {};
            zen-proxy = pkgs.callPackage ../../packages/zen-proxy.nix {};
        };
    };
}
