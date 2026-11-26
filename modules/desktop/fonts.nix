{inputs, ...}: {
    flake.modules.nixos.desktopFonts = {pkgs, ...}: let
        appleFonts = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};
    in {
        key = "shellix.nixos.desktopFonts";

        fonts = {
            packages = with pkgs; [
                appleFonts.sf-pro
                appleFonts.sf-mono
                appleFonts.ny
                maple-mono.NF
                noto-fonts
                weather-icons
                (callPackage ../../packages/switzer-font.nix {})
                (callPackage ../../packages/google-sans-flex.nix {})
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
