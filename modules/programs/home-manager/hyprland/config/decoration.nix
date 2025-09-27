{config, ...}: let
  colors = config.shellix.matugen.colors.palette;
in {
  decoration = {
    rounding = 5;
    rounding_power = 4.0;
    active_opacity = 1;
    inactive_opacity = 0.95;

    blur = {
      enabled = true;
      size = 7;
      special = false;
      passes = 3;
      brightness = 0.8;
      noise = 0.017;
      contrast = 0.8;
      popups = true;
      popups_ignorealpha = 0.6;
      new_optimizations = true;
      input_methods = true;
      input_methods_ignorealpha = 0.8;
      xray = true;
      ignore_opacity = true;
    };

    shadow = {
      enabled = false;
      ignore_window = true;
      range = 30;
      offset = "0 2";
      render_power = 4;
      color = "0x${colors.shadow.hex16bit}";
    };
  };
}
