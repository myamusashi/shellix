{
  decoration = {
    rounding = 8;
    rounding_power = 2.0;
    active_opacity = 1;
    inactive_opacity = 0.95;

    blur = {
      enabled = true;
      size = 5;
      special = false;
      passes = 1;
      brightness = 1;
      contrast = 0.89;
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
      color = "$shadow";
    };
  };
}
