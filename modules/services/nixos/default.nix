{lib, ...}: {
  imports = [
    ./audio.nix
    ./earlyoom.nix
    ./greetd.nix
    ./geoclue2.nix
    ./resolver.nix
    ./scx.nix
    ./plasma.nix
  ];

  options.shellix.services.nixos = {
    audio = {
      enable = lib.mkEnableOption "Enable audio using pipewire";
    };
    earlyoom = {
      enable = lib.mkEnableOption "Enable kill early OOM scheduler";
    };
    greetd = {
      enable = lib.mkEnableOption "Enable session manager";
    };
    geoclue2 = {
      enable = lib.mkEnableOption "Enable locations";
    };
    resolver = {
      enable = lib.mkEnableOption "Enable resolver using Cloudflare";
    };
    scx = {
      enable = lib.mkEnableOption "Enable scx framework scheduler";
    };
    plasma = {
      enable = lib.mkEnableOption "Enable plasma GUI";
    };
  };
}
