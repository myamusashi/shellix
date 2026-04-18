{lib, ...}: {
    imports = [
        ./mpv/default.nix
        ./btop/default.nix
        ./foot/default.nix
        ./htop/default.nix
        ./yazi/default.nix
        ./kitty/default.nix
        ./neovim/default.nix
        ./lazygit/default.nix
        ./neovide/default.nix
        ./hyprland/default.nix
        ./fastfetch/default.nix
        ./spicetify/default.nix
        ./quickshell/default.nix
        ./shell/defaults.nix
        ./vscode/default.nix
        ./winapps/default.nix
        ./matugen/default.nix
        ./winboat/default.nix
    ];

    options.shellix.programs.home = {
        mpv.enable = lib.mkEnableOption "Enable MPV applications";
        btop.enable = lib.mkEnableOption "Enable BTOP monitoring";
        foot.enable = lib.mkEnableOption "Enable Foot terminal applications";
        htop.enable = lib.mkEnableOption "Enable HTOP monitoring";
        yazi.enable = lib.mkEnableOption "Enable Yazi TUI file manager applications";
        kitty.enable = lib.mkEnableOption "Enable Kitty terminal applications";
        neovim.enable = lib.mkEnableOption "Enable Neovim code editor applications";
        lazygit.enable = lib.mkEnableOption "Enable Lazygit TUI applications";
        neovide.enable = lib.mkEnableOption "Enable Neovim wrapper written in rust";
        hyprland.enable = lib.mkEnableOption "Enable Hyprland wayland compositor";
        fastfetch.enable = lib.mkEnableOption "Enable Fastfetch system information";
        spicetify.enable = lib.mkEnableOption "Enable Spicetify spotify mod applications";
        quickshell.enable = lib.mkEnableOption "Enable Quickshell qt widget and shell applications";
        nushell.enable = lib.mkEnableOption "Enable Nushell shell applications";
        vscode.enable = lib.mkEnableOption "Enable VSCode code editor";
        winapps.enable = lib.mkEnableOption "Enable Winapps";
        shell.enable = lib.mkEnableOption "Enable shell widgets";
        matugen.enable = lib.mkEnableOption "Enable matugen color generation";
        winboat.enable = lib.mkEnableOption "Enable winboat seamless integration with windows";
    };
}
