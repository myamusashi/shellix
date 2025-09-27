{lib, ...}: {
  animations = {
    enabled = lib.mkDefault true;
    bezier = [
      "expressiveFastSpatial, 0.42, 1.67, 0.21, 0.90"
      "expressiveSlowSpatial, 0.39, 1.29, 0.35, 0.98"
      "expressiveDefaultSpatial, 0.38, 1.21, 0.22, 1.00"
      "emphasizedDecel, 0.05, 0.7, 0.1, 1"
      "emphasizedAccel, 0.3, 0, 0.8, 0.15"
      "standardDecel, 0, 0, 0, 1"
      "menu_decel, 0.1, 1, 0, 1"
      "menu_accel, 0.52, 0.03, 0.72, 0.08"
    ];
    animation = [
      "windowsIn, 1, 3, emphasizedDecel, slide"
      "windowsOut, 1, 2, emphasizedDecel, slide"
      "windowsMove, 1, 3, emphasizedDecel, slide"
      "workspaces, 1, 7, menu_decel, slide"
      "layersIn, 1, 4, expressiveDefaultSpatial, slide"
      "layersOut, 1, 4, expressiveDefaultSpatial, slide"
      "fadeLayers, 1, 6, menu_decel"
      "fadeDpms, 1, 2.7, menu_decel"
      "border, 1, 10, emphasizedDecel"
      "fade, 1, 0.5, menu_accel"
      "specialWorkspace, 1, 2, emphasizedAccel, slidefadevert 15%"
    ];
  };
}
