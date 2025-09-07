{config, ...}: let
  colors = config.shellix.matugen.colors.palette;
in {
  decoration = {
    rounding = 5;
    rounding_power = 4.0;
    active_opacity = 0.85;
    inactive_opacity = 0.79;

    blur = {
      enabled = true;
      size = 2;
      special = false;
      passes = 1;
      brightness = 1;
      noise = 0.01;
      contrast = 1;
      popups = true;
      popups_ignorealpha = 0.6;
      new_optimizations = true;
      input_methods = true;
      input_methods_ignorealpha = 0.8;
      xray = false;
      ignore_opacity = false;
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
