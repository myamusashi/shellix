{config, ...}: let
  colors = config.shellix.matugen.colors.palette;
in {
  rounding = 5;
  rounding_power = 4.0;
  active_opacity = 1;
  inactive_opacity = 0.9;

  blur = {
    enabled = true;
    size = 4;
    passes = 3;
    new_optimizations = true;
    input_methods = 1;
    xray = true;
    ignore_opacity = true;
  };

  shadow = {
    enabled = false;
    color = "0x${colors.shadow.hex16bit}";
    color_inactive = "0x${colors.surface_dim.hex16bit}";
  };
}
