{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.matugen;
    HOME = "/home/myamusashi";

    matugenConfig = ''
        [config.custom_colors]

        [templates.btop]
        input_path = "${toString ./templates/btop/btop.theme}"
        mode = "Dark"
        output_path = "${HOME}/.config/btop/themes/shellix.theme"

        [templates.discord]
        input_path = "${toString ./templates/discord/discord-theme.css}"
        mode = "Dark"
        output_path = "${HOME}/.config/vesktop/themes/shellix.theme.css"

        [templates.foot]
        input_path = "${toString ./templates/foot/foot.ini}"
        mode = "Dark"
        output_path = "${HOME}/.config/foot/foot.ini"

        [templates.vicinae]
        input_path = "${toString ./templates/vicinae/shellix.json}"
        mode = "Dark"
        output_path = "${HOME}/.config/vicinae/themes/shellix.json"

        [templates.gtk3]
        input_path = "${toString ./templates/gtk/gtk-colors.css}"
        mode = "Dark"
        output_path = "${HOME}/.config/gtk-3.0/gtk.css"

        [templates.gtk4]
        input_path = "${toString ./templates/gtk/gtk-colors.css}"
        mode = "Dark"
        output_path = "${HOME}/.config/gtk-4.0/gtk.css"

        [templates.hyprland_lua_colors]
        input_path = "${toString ./templates/hyprland/colors.lua}"
        mode = "Dark"
        output_path = "${HOME}/.config/hypr/colors-hypr-matugen.lua"

        [templates.kitty]
        input_path = "${toString ./templates/kitty/kitty-colors.conf}"
        mode = "Dark"
        output_path = "${HOME}/.config/kitty/shellix.conf"

        [templates.kvantum]
        input_path = "${toString ./templates/kvantum/kvantum.kvconfig}"
        mode = "Dark"
        output_path = "${HOME}/.config/Kvantum/Shellix-matugen/Shellix-matugen.kvconfig"

        [templates.color_scheme]
        input_path = "${toString ./templates/color-scheme/Shellix.colors}"
        mode = "Dark"
        output_path = "${HOME}/.local/share/color-schemes/Shellix.colors"

        [templates.lazygit]
        input_path = "${toString ./templates/lazygit/lazygit-theme.yml}"
        mode = "Dark"
        output_path = "${HOME}/.config/lazygit/config.yml"

        [templates.qt6ct]
        input_path = "${toString ./templates/qtct/qtct-colors.conf}"
        mode = "Dark"
        output_path = "${HOME}/.config/qt6ct/colors/shellix.conf"

        [templates.starship]
        input_path = "${toString ./templates/starship/starship.colors}"
        mode = "Dark"
        output_path = "${HOME}/.config/starship.toml"

        [templates.yazi]
        input_path = "${toString ./templates/yazi/yazi-theme.conf}"
        mode = "Dark"
        output_path = "${HOME}/.config/yazi/flavors/shellix.yazi/flavor.toml"

        [templates.zellij]
        input_path = "${toString ./templates/zellij/zellij-colors.kdl}"
        mode = "Dark"
        output_path = "${HOME}/.config/zellij/themes/shellix.kdl"

        [templates.shell]
        input_path = "${toString ./templates/shell/colors-dark.json}"
        mode = "Dark"
        output_path = "${HOME}/.config/vast-shell/dark-colors.json"

        [templates.shell_light]
        input_path = "${toString ./templates/shell/colors-light.json}"
        mode = "Light"
        output_path = "${HOME}/.config/vast-shell/light-colors.json"
    '';
    #
    # [templates.zen_usercontent]
    # input_path = "${toString ./templates/zen/userContent.css}"
    # mode = "Dark"
    # output_path = "${HOME}/.zen/kxhdnjqx.zen/chrome/userContent.css"
    #
    # [templates.zen_userchrome]
    # input_path = "${toString ./templates/zen/userChrome.css}"
    # mode = "Dark"
    # output_path = "${HOME}/.zen/kxhdnjqx.zen/chrome/userChrome.css"
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.matugen];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/matugen 0755 myamusashi users - -"
            "L+ %h/.config/matugen/config.toml - - - - ${pkgs.writeText "matugen-config" matugenConfig}"
            "d %h/.config/Kvantum 0755 myamusashi users - -"
            "d %h/.config/Kvantum/Shellix-matugen 0755 myamusashi users - -"
            "L+ %h/.config/Kvantum/Shellix-matugen/Shellix-matugen.svg - - - - ./templates/kvantum/MaterialAdw.svg"
        ];
    };
}
