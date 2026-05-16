{
    lib,
    inputs,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.home.neovim;
in {
    config = lib.mkIf cfg.enable {
        programs.neovim = {
            enable = true;
            package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

            plugins = with pkgs.vimPlugins; [
                (nvim-treesitter.withPlugins (p: [
                    p.typescript
                    p.tsx
                    p.javascript
                    p.html
                    p.css
                    p.svelte
                    p.dart
                    p.qmljs
                    p.json
                    p.json5
                    p.nix
                    p.lua
                    p.bash
                    p.markdown
                    p.markdown_inline
                    p.yaml
                    p.toml
                    p.dockerfile
                    p.sql
                    p.cpp
                    p.c
                    p.fish
                    p.arduino
                ]))
            ];

            initLua = ''
                require("config.lazy")
                require("config.neovide")
                require("config.keymaps")
                require("config.options")
                require("config.core")
            '';

            extraPackages = with pkgs; [
                lua-language-server
                bash-language-server
                vscode-langservers-extracted
                docker-language-server
                fish-lsp
                mesonlsp
                sqls
                arduino-language-server
                llvm
                clang
                nil

                stylua
                luaformatter
                shfmt
                prettierd
                markdownlint-cli2

                arduino-cli
                ripgrep
                bun
                pnpm
                yarn
                live-server
                marksman
                kdePackages.qtdeclarative
                inputs.qml-language-server.packages.${stdenv.hostPlatform.system}.default

                gcc
                gnumake
                tree-sitter
            ];
        };
    };
}
