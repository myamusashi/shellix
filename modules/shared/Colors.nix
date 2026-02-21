{
    config,
    lib,
    ...
}:
with lib; let
    colorType = types.submodule {
        options = {
            hex = mkOption {
                type = types.str;
                description = "Hex color value, example: #000000";
            };
            rgb = mkOption {
                type = types.str;
                description = "RGB color value, example: rgb(255,255,255)";
            };
            rgb-strip = mkOption {
                type = types.str;
                description = "RGB color value but strip, example: 255,255,255";
            };
            strip = mkOption {
                type = types.str;
                description = "Same as hex without #, example: 000000";
            };
            rgba = mkOption {
                type = types.str;
                description = "RGB with Alpha color, example: rgba(255,255,255, 0.5/1)";
            };
            hex16bit = mkOption {
                type = types.str;
                description = "Hex with 16 bit values: example: ffffb3b6 or 0xffffb3b6";
            };
        };
    };
in {
    options.shellix.matugen.colors = {
        enable = mkEnableOption "color system";

        hex = mkOption {
            type = types.attrsOf types.str;
            readOnly = true;
            description = "Palet warna lengkap dalam format hex.";
        };

        rgb = mkOption {
            type = types.attrsOf types.str;
            readOnly = true;
            description = "Palet warna lengkap dalam format rgb.";
        };

        rgb-strip = mkOption {
            type = types.attrsOf types.str;
            readOnly = true;
            description = "Palet warna lengkap dalam format rgb.";
        };

        rgba = mkOption {
            type = types.attrsOf types.str;
            readOnly = true;
            description = "Palet warna lengkap dalam format rgba.";
        };

        strip = mkOption {
            type = types.attrsOf types.str;
            readOnly = true;
            description = "Palet warna lengkap dalam format hex tanpa '#'.";
        };

        hex16bit = mkOption {
            type = types.attrsOf types.str;
            readOnly = true;
            description = "Palet warna lengkap dalam format hex 16-bit (ARGB).";
        };

        palette = mkOption {
            type = types.attrsOf colorType;
            readOnly = true;
            description = "palette colors";
            example = literalExpression "config.shellix.matugen.colors.palette.primary.hex";
        };
    };

    config = mkIf config.shellix.matugen.colors.enable {
        shellix.matugen.colors = let
            colorDataPath = ./Palette;

            hexColors = import (colorDataPath + "/hex.nix");
            rgbColors = import (colorDataPath + "/rgb.nix");
            rgbStripColors = import (colorDataPath + "/rgb-strip.nix");
            rgbaColors = import (colorDataPath + "/rgba.nix");
            stripColors = import (colorDataPath + "/strip.nix");
            hex16bitColors = import (colorDataPath + "/hex16bit.nix");
        in {
            hex = hexColors;
            rgb = rgbColors;
            rgb-strip = rgbStripColors;
            rgba = rgbaColors;
            strip = stripColors;
            hex16bit = hex16bitColors;

            palette = mapAttrs (name: value: {
                hex = hexColors."${name}";
                rgb = rgbColors."${name}";
                rgb-strip = rgbStripColors."${name}";
                rgba = rgbaColors."${name}";
                strip = stripColors."${name}";
                hex16bit = hex16bitColors."${name}";
            })
            hexColors;
        };
    };
}
