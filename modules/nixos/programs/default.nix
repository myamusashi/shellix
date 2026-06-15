{lib, ...}: {
    imports = [
        ./btop.nix
        ./fastfetch.nix
        ./foot.nix
        ./htop.nix
        ./kitty.nix
        ./lazygit.nix
        ./mpv.nix
        ./neovide.nix
        ./neovim.nix
        ./quickshell.nix
        ./shell.nix
        ./spicetify.nix
		./virt-manager.nix
        ./vscode.nix
        ./fish/default.nix
        ./matugen/default.nix
        ./yazi/default.nix
    ];

    options.shellix.programs = with lib; {
        btop.enable = mkEnableOption "Enable btop resource monitoring";
        fastfetch.enable = mkEnableOption "Enable terminal system info";
        fish.enable = mkEnableOption "Enable fish shell";
        foot.enable = mkEnableOption "Enable lightweight foot terminal";
        htop.enable = mkEnableOption "Enable htop resource monitoring";
        kitty.enable = mkEnableOption "Enable GPU accelerated kitty terminal";
        lazygit.enable = mkEnableOption "Enable TUI git management";
        mpv.enable = mkEnableOption "Enable lightweight and feature rich video player";
        neovide.enable = mkEnableOption "Enable neovim client built onRust";
        neovim.enable = mkEnableOption "Enable neovim, lightweight terminal editor";
        quickshell.enable = mkEnableOption "Enable quickshell wrapper";
        shell.enable = mkEnableOption "Enable shell for wm GUI";
        spicetify.enable = mkEnableOption "Enable spotify mod";
        vscode.enable = mkEnableOption "Enable electron code editor";
        matugen.enable = mkEnableOption "Enable auto color generation based on wallpaper";
        yazi.enable = mkEnableOption "Enable Yazi terminal file manager built on Rust";
		virt-manager.enable = mkEnableOption "Enable libvirt for virtualization using Qemu";
    };
}
