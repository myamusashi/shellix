{
    config,
    lib,
    ...
}: let
    cfg = config.shellix.programs.color-templates;

    templates = [
        {
            input = ./templates/btop/btop.theme;
            output = ".config/btop/themes/shellix.theme";
        }
        {
            input = ./templates/discord/discord-theme.css;
            output = ".config/vesktop/themes/shellix.theme.css";
        }
        {
            input = ./templates/foot/foot.ini;
            output = ".config/foot/foot.ini";
        }
        {
            input = ./templates/gtk/gtk-colors.css;
            output = ".config/gtk-3.0/gtk.css";
        }
        {
            input = ./templates/gtk/gtk-colors.css;
            output = ".config/gtk-4.0/gtk.css";
        }
        {
            input = ./templates/hyprland/colors.lua;
            output = ".config/hypr/colors-hypr-matugen.lua";
        }
        {
            input = ./templates/kitty/kitty-colors.conf;
            output = ".config/kitty/shellix.conf";
        }
        {
            input = ./templates/kvantum/kvantum.kvconfig;
            output = ".config/Kvantum/Shellix-matugen/Shellix-matugen.kvconfig";
        }
        {
            input = ./templates/color-scheme/Shellix.colors;
            output = ".local/share/color-schemes/Shellix.colors";
        }
        {
            input = ./templates/lazygit/lazygit-theme.yml;
            output = ".config/lazygit/config.yml";
        }
        {
            input = ./templates/qtct/qtct-colors.conf;
            output = ".config/qt6ct/colors/shellix.conf";
        }
        {
            input = ./templates/starship/starship.colors;
            output = ".config/starship.toml";
        }
        {
            input = ./templates/yazi/yazi-theme.conf;
            output = ".config/yazi/flavors/shellix.yazi/flavor.toml";
        }
        {
            input = ./templates/zellij/zellij-colors.kdl;
            output = ".config/zellij/themes/shellix.kdl";
        }
        {
            input = ./templates/loaf-theme/colors.json;
            output = ".local/state/quickshell/user/generated/colors.json";
        }
        {
            input = ./templates/zapfast/shellix.json;
            output = ".config/zapfast/Shellix.json";
        }
    ];

    outputDirectories = lib.unique (map (template: builtins.dirOf template.output) templates);
    directoryRules = map (directory: "d %h/${directory} 0755 - - - -") outputDirectories;
    templateRules = map (template: "L+ %h/${template.output}.tmpl - - - - ${template.input}") templates;
in {
    config = lib.mkIf cfg.enable {
        systemd.user.tmpfiles.rules =
            directoryRules
            ++ templateRules
            ++ [
                "L+ %h/.config/Kvantum/Shellix-matugen/Shellix-matugen.svg - - - - ${./templates/kvantum/MaterialAdw.svg}"
            ];
    };
}
