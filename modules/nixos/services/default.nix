{lib, ...}: {
  imports = [
    ./audio.nix
    ./earlyoom.nix
    ./geoclue2.nix
    ./resolver.nix
    ./scx.nix
    ./borg.nix
    ./plasma.nix
    ./display-manager.nix
    ./minidlna.nix
    ./systemd/cachix.nix
    ./systemd/stirling.nix
    ./systemd/cloudflare-tunnels.nix
    ./kdeconnect.nix
    ./clipse.nix
    ./easyeffects
    ./hypridle.nix
    ./mpd.nix
    ./systemd/shell.nix
    ./systemd/nm-applet.nix
  ];

  options.shellix.services = {
    audio.enable = lib.mkEnableOption "Enable audio using pipewire";
    earlyoom.enable = lib.mkEnableOption "Enable kill early OOM scheduler";
    geoclue2.enable = lib.mkEnableOption "Enable locations";
    resolver.enable = lib.mkEnableOption "Enable resolver using Cloudflare";
    scx.enable = lib.mkEnableOption "Enable scx framework scheduler";
    plasma.enable = lib.mkEnableOption "Enable plasma GUI";
    minidlna.enable = lib.mkEnableOption "Enable MiniDLNA";

    # Migrated services
    kdeconnect.enable = lib.mkEnableOption "Enable kde-connect";
    clipse.enable = lib.mkEnableOption "Enable clipboard manager";
    hypridle.enable = lib.mkEnableOption "Enable idle manager";
    mpd.enable = lib.mkEnableOption "Enable MPD players services";

    systemd = {
      cachix.enable = lib.mkEnableOption "Enable cachix daemon";
      stirling.enable = lib.mkEnableOption "Enable stirling PDF services";
      cloudflare-tunnels.enable = lib.mkEnableOption "Enable cloudflare-tunnels keys for running cloudflare services";
      shell.enable = lib.mkEnableOption "Enable vast-shell quickshell";
      nm-applet.enable = lib.mkEnableOption "Enable network manger applet tray widgets";
    };
  };
}
