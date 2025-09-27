{config, ...}: {
  enable = true;
  text = ''
    theme {
      color_scheme = ${config.home.homeDirectory}/.config/hypr/colors/shellix.colors
      icon_theme = Papirus
      style = kvantum-dark
      font_fixed = Hack
      font = Inter
      font_size = 12
      font_fixed_size = 12
    }

    misc {
      single_click_activate = true
      menus_have_icons = true
      shortcuts_for_context_menus = true
    }
  '';
}
