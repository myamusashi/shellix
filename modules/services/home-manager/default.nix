{lib, ...}: {
    imports = [
        ./clipse/default.nix
        ./hypridle/default.nix
        ./easyeffects/default.nix
        ./kdeconnect/default.nix
        ./mpd/default.nix
        ./systemd/shell.nix
        ./systemd/nm-applet.nix
    ];

    options.shellix.services.home-manager = {
        clipse.enable = lib.mkEnableOption "Enable clipboard manager";
        hypridle.enable = lib.mkEnableOption "Enable idle manager";
        easyeffects.enable = lib.mkEnableOption "Enable audio I/O manager";
        kdeconnect.enable = lib.mkEnableOption "Enable kde-connect";
        mpd.enable = lib.mkEnableOption "Enable MPD players services";
        systemd = {
            shell.enable = lib.mkEnableOption "Enable vast-shell quickshell";
            nm-applet.enable = lib.mkEnableOption "Enable network manger applet tray widgets";
        };
    };
}
