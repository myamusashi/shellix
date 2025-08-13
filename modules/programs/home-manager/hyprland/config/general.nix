{config, ...}: let
  colors = config.shellix.matugen.colors.palette;
in {
  gaps_in = 2;
  gaps_out = 5;
  border_size = 5;
  "col.active_border" = "0x${colors.primary.hex16bit} 0x${colors.primary_container.hex16bit} 45deg";
  "col.inactive_border" = "0x${colors.inverse_primary.hex16bit}";
  no_border_on_floating = false;
  layout = "hy3";
  snap = {
    enabled = true;
    window_gap = 35;
    monitor_gap = 35;
  };
}
