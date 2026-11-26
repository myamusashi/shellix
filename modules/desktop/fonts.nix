{inputs, ...}: {
    flake.modules.nixos.desktopFonts = {pkgs, ...}: let
        appleFonts = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};
    in {
        key = "shellix.nixos.desktopFonts";

        fonts = {
            packages = [
                appleFonts.sf-pro
                appleFonts.sf-mono
                appleFonts.ny
                pkgs.maple-mono.NF
                pkgs.noto-fonts
                pkgs.weather-icons
                (pkgs.callPackage ../../packages/switzer-font.nix {})
                (pkgs.callPackage ../../packages/google-sans-flex.nix {})
            ];
            enableDefaultPackages = true;
            fontconfig = {
                enable = true;
                antialias = true;
                hinting = {
                    enable = true;
                    style = "slight";
                    autohint = false;
                };
                subpixel = {
                    rgba = "rgb";
                    lcdfilter = "default";
                };
                defaultFonts = {
                    serif = ["New York"];
                    monospace = ["SF Mono"];
                    sansSerif = ["SF Pro"];
                };
            };
        };
    };
}
