{config, ...}: let
  cfg = config.shellix.programs.home.hyprland;
  layoutHypr =
    if cfg.plugins.hy3.keybind
    then "hy3"
    else if cfg.plugins.scrolling.keybind
    then "scrolling"
    else "dwindle";
in {
  general = {
    gaps_in = 5;
    gaps_out = 5;
    border_size = 5;
    "col.active_border" = "$primary";
    "col.inactive_border" = "$inverse_primary";
    layout = layoutHypr;
    snap = {
      enabled = true;
      window_gap = 35;
      monitor_gap = 35;
    };
  };
}
