{lib, ...}: {
  imports = [
    ./clipse/default.nix
    ./hypridle/default.nix
    ./easyeffects/default.nix
    ./kdeconnect/default.nix
    ./mpd/default.nix
    # ./vicinae/default.nix
  ];

  options.shellix.services.home-manager = {
    clipse.enable = lib.mkEnableOption "Enable clipboard manager";
    hypridle.enable = lib.mkEnableOption "Enable idle manager";
    easyeffects.enable = lib.mkEnableOption "Enable audio I/O manager";
    kdeconnect.enable = lib.mkEnableOption "Enable kde-connect";
    mpd.enable = lib.mkEnableOption "Enable MPD players services";
    # vicinae.enable = lib.mkEnableOption "Enable vicinae";
  };
}
