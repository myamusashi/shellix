{
  systemd.user.startServices = true;

  imports = [
    ./modules/adzan/default.nix
    ./modules/get_adzan_data/default.nix
    ./modules/swww/swww.nix
    ./modules/nm_applet/default.nix
  ];
}
