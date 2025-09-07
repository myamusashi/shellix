{config, ...}: let
  colors = config.shellix.matugen.colors.palette;
in {
  misc = {
    disable_hyprland_logo = true;
    background_color = "0x${colors.background.hex16bit}";
    disable_splash_rendering = true;
    disable_autoreload = false;
    mouse_move_enables_dpms = true;
    vfr = true;
    font_family = "CaskaydiaMono Nerd Font";
    vrr = 0;
    animate_manual_resizes = false;
    mouse_move_focuses_monitor = true;
    enable_swallow = true;
    animate_mouse_windowdragging = false;
    middle_click_paste = false;
  };
}
