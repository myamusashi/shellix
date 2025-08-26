{
  lib,
  config,
  ...
}: let
  cfg = config.shellix.programs.home.kitty;
  colors = config.shellix.matugen.colors.palette;
in {
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = lib.mkDefault true;
      # themeFile = "3024_Night";
      keybindings = {
        "ctrl+g" = "lazygit";
      };
      settings = {
        confirm_os_window_close = 0;

        font_size = 11.0;

        cursor_trail = 2;
        cursor_trail_decay = "0.1 0.4";
        cursor_shape = "beam";
        cursor_beam_thickness = 1.5;
        cursor_underline_thickness = 2.0;
        cursor_stop_blinking_after = 15.0;
        cursor_trail_start_threshold = 0;
        shell_integration = "no-cursor";

        disable_ligatures = "never";

        scrollback_lines = 2000;

        wheel_scroll_multiplier = 5.0;
        mouse_hide_wait = 3.0;

        detect_urls = true;
        url_style = "curly";
        open_url_with = "default";

        copy_on_select = false;
        strip_trailing_spaces = "never";

        focus_follows_mouse = false;

        default_pointer_shape = "beam";

        repaint_delay = 1;
        input_delay = 1;
        sync_to_monitor = false;
        enable_audio_bell = false;

        enabled_layouts = "grid";
        window_resize_step_cells = 2;
        window_resize_step_lines = 2;
        window_border_width = "0.5pt";
        draw_minimal_borders = true;
        window_margin_width = 0;
        single_window_margin_width = -1;
        window_padding_width = 0;
        placement_strategy = "center";
        active_border_color = colors.tertiary.hex;
        inactive_border_color = colors.inverse_on_surface.hex;
        inactive_text_alpha = 1.0;
        hide_window_decorations = false;
        tab_bar_style = "powerline";
        tab_separator = " ┇";

        background_opacity = 0.8;
        background_image = "none";
        background_image_layout = "tiled";
        background_image_linear = false;
        dynamic_background_opacity = true;
        background_tint = 1;
        dim_opacity = 1;

        font_family = "Inconsolata LGC Nerd Font";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";

        # Custom theme

        # UI
        foreground = colors.on_surface.hex;
        background = colors.surface.hex;
        selection_foreground = colors.on_secondary.hex;
        selection_background = colors.secondary_fixed_dim.hex;
        url_color = colors.primary.hex;

        # Cursor
        cursor = colors.on_surface.hex;
        cursor_text_color = colors.on_surface.hex;

        # Black
        color0 = "#262626";
        color8 = "#4c4c4c";

        # red
        color1 = "#da2c20";
        color9 = "#e8bacf";

        # green
        color2 = "#00a152";
        color10 = "#3a3332";

        # yellow
        color3 = "#fcec02";
        color11 = "#494542";

        # blue
        color4 = "#00a0e4";
        color12 = "#7f7c7b";

        # magenta
        color5 = "#a06994";
        color13 = "#d6d4d3";

        # cyan
        color6 = "#b5e4f4";
        color14 = "#ccab53";

        # white
        color7 = "#a4a1a1";
        color15 = "#f7f7f7";
      };
    };
  };
}
