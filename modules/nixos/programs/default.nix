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
        fish = {
            enable = mkEnableOption "Enable fish shell";
            username = lib.mkOption {
                type = lib.types.str;
                example = "myamusashi";
                description = "Ther user gonna use this shell of course";
            };
            setAsDefaultShell = lib.mkEnableOption "Set fish as the default user shell";
        };
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

            languages = {
                web = lib.mkEnableOption "web dev (TS/JS/HTML/CSS/Svelte/Tailwind)" // {default = true;};
                lua = lib.mkEnableOption "Lua dev" // {default = true;};
                nix = lib.mkEnableOption "Nix dev" // {default = true;};
                python = lib.mkEnableOption "Python dev" // {default = true;};
                cpp = lib.mkEnableOption "C/C++ dev" // {default = true;};
                bash = lib.mkEnableOption "Bash dev" // {default = true;};
                fish = lib.mkEnableOption "Fish dev" // {default = true;};
                docker = lib.mkEnableOption "Docker dev" // {default = true;};
                markdown = lib.mkEnableOption "Markdown & LaTeX" // {default = true;};
                data = lib.mkEnableOption "JSON / YAML / TOML" // {default = true;};
                qml = lib.mkEnableOption "QML dev" // {default = true;};
                dart = lib.mkEnableOption "Dart dev" // {default = true;};
                sql = lib.mkEnableOption "SQL dev" // {default = true;};
                meson = lib.mkEnableOption "Meson build system" // {default = true;};
                lint = lib.mkEnableOption "oxlint / oxfmt linting" // {default = true;};
            };

            extraPackages = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [];
                description = "LSP servers, formatters, and tools available to nvim";
            };

            excludePackages = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [];
                description = "Exclude specific packages from the runtime environment";
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
            username = lib.mkOption {
                type = lib.types.str;
                example = "myamusashi";
                description = "Ther user gonna use this shell of course";
            };

            setAsDefaultShell = lib.mkEnableOption "Set nushell as the default user shell";
        };
        virt-manager.enable = mkEnableOption "Enable libvirt for virtualization using Qemu";
        wireshark.enable = mkEnableOption "Enable network listener";
    };
}
