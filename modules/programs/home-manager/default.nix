{lib, ...}: {
  imports = [
    ./mpv/default.nix
    ./btop/default.nix
    ./foot/default.nix
    ./htop/default.nix
    ./wofi/default.nix
    ./yazi/default.nix
    ./kitty/default.nix
    ./fuzzel/default.nix
    ./neovim/default.nix
    ./lazygit/default.nix
    ./neovide/default.nix
    ./hyprland/default.nix
    ./fastfetch/default.nix
    ./spicetify/default.nix
    ./quickshell/default.nix
  ];

  options.shellix.programs.home = {
    enable = lib.mkEnableOption "Programs management module";
  };
}
