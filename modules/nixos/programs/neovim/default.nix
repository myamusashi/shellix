{
    lib,
    inputs,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.neovim;
    lang = cfg.languages;

    runtimePackages = with pkgs;
        lib.optionals lang.web [
            typescript-language-server
            javascript-typescript-langserver
            svelte-language-server
            tailwindcss-language-server
            vscode-langservers-extracted
            inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.csskit
            typescript
            nodejs
            yarn
            pnpm
        ]
        ++ lib.optionals lang.lua [
            lua-language-server
        ]
        ++ lib.optionals lang.markdown [
            marksman
            ltex-ls-plus
        ]
        ++ lib.optionals lang.python [
            pyright
            python3
        ]
        ++ lib.optionals lang.nix [
            nil
        ]
        ++ lib.optionals lang.qml [
            kdePackages.qtdeclarative
        ]
        ++ lib.optionals lang.cpp [
            cmake-language-server
            clang-tools
            clang
        ]
        ++ lib.optionals lang.meson [
            mesonlsp
        ]
        ++ lib.optionals lang.lint [
            oxlint
            oxfmt
        ]
        ++ lib.optionals lang.docker [
            docker-language-server
        ]
        ++ lib.optionals lang.fish [
            fish-lsp
        ]
        ++ lib.optionals lang.bash [
            shfmt
            shellcheck
        ]
        ++ [tree-sitter pkgs.stdenv.cc];

    treesitterParsers = with pkgs.tree-sitter-grammars;
        lib.optionals lang.web [
            tree-sitter-typescript
            tree-sitter-tsx
            tree-sitter-javascript
            tree-sitter-html
            tree-sitter-css
            tree-sitter-svelte
        ]
        ++ lib.optionals lang.lua [
            tree-sitter-lua
        ]
        ++ lib.optionals lang.nix [
            tree-sitter-nix
        ]
        ++ lib.optionals lang.bash [
            tree-sitter-bash
        ]
        ++ lib.optionals lang.markdown [
            tree-sitter-markdown
            tree-sitter-markdown-inline
        ]
        ++ lib.optionals lang.data [
            tree-sitter-json
            tree-sitter-json5
            tree-sitter-yaml
            tree-sitter-toml
        ]
        ++ lib.optionals lang.docker [
            tree-sitter-dockerfile
        ]
        ++ lib.optionals lang.sql [
            tree-sitter-sql
        ]
        ++ lib.optionals lang.cpp [
            tree-sitter-cpp
            tree-sitter-c
        ]
        ++ lib.optionals lang.qml [
            tree-sitter-qmljs
        ]
        ++ lib.optionals lang.dart [
            tree-sitter-dart
        ]
        ++ lib.optionals lang.fish [
            tree-sitter-fish
        ];

    neovimWrapped = pkgs.wrapNeovimUnstable
    inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.neovim
    {
        plugins = [
            (pkgs.vimPlugins.nvim-treesitter.withPlugins (_: treesitterParsers))
        ];
        wrapRc = false;
        inherit (cfg) viAlias vimAlias vimdiffAlias extraPackages;
    };
in {
    config = lib.mkIf cfg.enable {
        environment = {
            systemPackages =
                [
                    neovimWrapped
                ]
                ++ lib.subtractLists cfg.excludePackages runtimePackages;

            sessionVariables = lib.mkIf cfg.defaultEditor {
                EDITOR = lib.mkForce "nvim";
                VISUAL = lib.mkForce "nvim";
            };
            shellAliases = lib.mkIf cfg.vimdiffAlias {
                vimdiff = "nvim -d";
            };
        };
    };
}
