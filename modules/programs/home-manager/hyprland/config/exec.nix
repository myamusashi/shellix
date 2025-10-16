{pkgs, ...}: {
  exec-once = [
    "udiskie --appindicator --menu-update-workaround --file-manager pcmanfm-qt --tray --notify --automount"
    "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
    "hyprctl dispatch workspace 1"
  ];
}
