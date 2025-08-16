{pkgs, ...}: {
  exec-once = [
    "udiskie --appindicator --menu-update-workaround --file-manager nautilus --tray --notify --automount"
    "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
  ];
}
