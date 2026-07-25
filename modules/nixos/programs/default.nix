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
        ./shell.nix
        ./spicetify.nix
        ./steam.nix
        ./virt-manager.nix
        ./vscode.nix
        ./wireshark.nix
        ./fish/default.nix
        ./matugen/default.nix
        ./neovim/default.nix
        ./nushell/default.nix
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
        neovim = {
            enable = lib.mkEnableOption "Enable Neovim with treesitter and LSP tools";

            viAlias = lib.mkEnableOption "vi alias";
            vimAlias = lib.mkEnableOption "vim alias";
            vimdiffAlias = lib.mkEnableOption "vimdiff alias";
            defaultEditor = lib.mkEnableOption "default editor" // {default = true;};

            extraPackages = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [];
                description = "LSP servers, formatters, and tools available to nvim";
            };
        };
        shell.enable = mkEnableOption "Enable shell for wm GUI";
        spicetify.enable = mkEnableOption "Enable spotify mod";
        steam.enable = mkEnableOption "Enable steam client";
        vscode.enable = mkEnableOption "Enable electron code editor";
        matugen.enable = mkEnableOption "Enable auto color generation based on wallpaper";
        yazi.enable = mkEnableOption "Enable Yazi terminal file manager built on Rust";
        nushell = {
            enable = lib.mkEnableOption "Enable nushell";
            setAsDefaultShell = lib.mkEnableOption "Set nushell as the default user shell";
        };
        virt-manager.enable = mkEnableOption "Enable libvirt for virtualization using Qemu";
        wireshark.enable = mkEnableOption "Enable network listener";
    };
}
