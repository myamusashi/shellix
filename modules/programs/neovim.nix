{inputs, ...}: {
    flake.modules.nixos.neovim = {
        config,
        lib,
        pkgs,
        ...
    }: let
        neovimConfig = config.shellix.neovim;
        inherit (neovimConfig) languages;

        runtimePackages =
            lib.optionals languages.web [
                pkgs.typescript-language-server
                pkgs.javascript-typescript-langserver
                pkgs.svelte-language-server
                pkgs.tailwindcss-language-server
                pkgs.vscode-langservers-extracted
                pkgs.typescript
                pkgs.nodejs
                pkgs.yarn
                pkgs.pnpm
            ]
            ++ lib.optionals languages.php [
                pkgs.intelephense
                pkgs.php
                pkgs.php84Packages.php-cs-fixer
                pkgs.phpstan
            ]
            ++ lib.optionals languages.lua [
                pkgs.lua-language-server
            ]
            ++ lib.optionals languages.markdown [
                pkgs.marksman
            ]
            ++ lib.optionals languages.python [
                pkgs.pyright
                pkgs.python3
            ]
            ++ lib.optionals languages.nix [
                pkgs.nil
            ]
            ++ lib.optionals languages.qml [
                pkgs.kdePackages.qtdeclarative
            ]
            ++ lib.optionals languages.cpp [
                pkgs.cmake-language-server
                pkgs.clang-tools
                pkgs.clang
            ]
            ++ lib.optionals languages.meson [
                pkgs.mesonlsp
            ]
            ++ lib.optionals languages.lint [
                pkgs.oxlint
                pkgs.oxfmt
            ]
            ++ lib.optionals languages.docker [
                pkgs.docker-language-server
            ]
            ++ lib.optionals languages.fish [
                pkgs.fish-lsp
            ]
            ++ lib.optionals languages.bash [
                pkgs.shfmt
                pkgs.shellcheck
            ]
            ++ [
                pkgs.tree-sitter
                pkgs.cargo
                pkgs.stdenv.cc
            ];

        grammars = pkgs.tree-sitter-grammars;
        treesitterParsers =
            lib.optionals languages.web [
                grammars.tree-sitter-typescript
                grammars.tree-sitter-tsx
                grammars.tree-sitter-javascript
                grammars.tree-sitter-html
                grammars.tree-sitter-css
                grammars.tree-sitter-svelte
            ]
            ++ lib.optionals languages.php [
                grammars.tree-sitter-php
            ]
            ++ lib.optionals languages.lua [
                grammars.tree-sitter-lua
            ]
            ++ lib.optionals languages.nix [
                grammars.tree-sitter-nix
            ]
            ++ lib.optionals languages.bash [
                grammars.tree-sitter-bash
            ]
            ++ lib.optionals languages.markdown [
                grammars.tree-sitter-markdown
                grammars.tree-sitter-markdown-inline
            ]
            ++ lib.optionals languages.data [
                grammars.tree-sitter-json
                grammars.tree-sitter-json5
                grammars.tree-sitter-yaml
                grammars.tree-sitter-toml
            ]
            ++ lib.optionals languages.docker [
                grammars.tree-sitter-dockerfile
            ]
            ++ lib.optionals languages.sql [
                grammars.tree-sitter-sql
            ]
            ++ lib.optionals languages.cpp [
                grammars.tree-sitter-cpp
                grammars.tree-sitter-c
            ]
            ++ lib.optionals languages.qml [
                grammars.tree-sitter-qmljs
            ]
            ++ lib.optionals languages.dart [
                grammars.tree-sitter-dart
            ]
            ++ lib.optionals languages.fish [
                grammars.tree-sitter-fish
            ];

        neovimWrapped =
            pkgs.wrapNeovimUnstable
            inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.neovim
            {
                plugins = [
                    (pkgs.vimPlugins.nvim-treesitter.withPlugins (_: treesitterParsers))
                ];
                wrapRc = false;
                inherit (neovimConfig) viAlias vimAlias vimdiffAlias extraPackages;
            };

        mkDefaultEnabledLanguage = description:
            lib.mkEnableOption description // {default = true;};
    in {
        options.shellix.neovim = {
            viAlias = lib.mkEnableOption "vi alias";
            vimAlias = lib.mkEnableOption "vim alias";
            vimdiffAlias = lib.mkEnableOption "vimdiff alias";
            defaultEditor = lib.mkEnableOption "default editor" // {default = true;};

            languages = {
                web = mkDefaultEnabledLanguage "web dev (TS/JS/HTML/CSS/Svelte/Tailwind)";
                php = mkDefaultEnabledLanguage "PHP dev";
                lua = mkDefaultEnabledLanguage "Lua dev";
                nix = mkDefaultEnabledLanguage "Nix dev";
                python = mkDefaultEnabledLanguage "Python dev";
                cpp = mkDefaultEnabledLanguage "C/C++ dev";
                bash = mkDefaultEnabledLanguage "Bash dev";
                fish = mkDefaultEnabledLanguage "Fish dev";
                docker = mkDefaultEnabledLanguage "Docker dev";
                markdown = mkDefaultEnabledLanguage "Markdown & LaTeX";
                data = mkDefaultEnabledLanguage "JSON / YAML / TOML";
                qml = mkDefaultEnabledLanguage "QML dev";
                dart = mkDefaultEnabledLanguage "Dart dev";
                sql = mkDefaultEnabledLanguage "SQL dev";
                meson = mkDefaultEnabledLanguage "Meson build system";
                lint = mkDefaultEnabledLanguage "oxlint / oxfmt linting";
            };

            extraPackages = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [];
                description = "LSP servers, formatters, and tools available to Neovim.";
            };

            excludePackages = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [];
                description = "Exclude specific packages from the runtime environment.";
            };
        };

        config = {
            environment = {
                systemPackages =
                    [neovimWrapped]
                    ++ lib.subtractLists neovimConfig.excludePackages runtimePackages;

                sessionVariables = lib.mkIf neovimConfig.defaultEditor {
                    EDITOR = lib.mkForce "nvim";
                    VISUAL = lib.mkForce "nvim";
                };
                shellAliases = lib.mkIf neovimConfig.vimdiffAlias {
                    vimdiff = "nvim -d";
                };
            };
        };
    };
}
