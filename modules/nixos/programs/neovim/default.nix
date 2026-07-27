{
    lib,
    inputs,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.neovim;

    runtimePackages = with pkgs; [
        typescript-language-server
        javascript-typescript-langserver
        svelte-language-server
        lua-language-server
        ltex-ls-plus
        pyright
        tailwindcss-language-server
        nil
        kdePackages.qtdeclarative
        marksman
        mesonlsp
        oxlint
        oxfmt
        vscode-langservers-extracted
        inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.csskit
        docker-language-server
        cmake-language-server
        clang-tools
        fish-lsp

        shfmt
        shellcheck

        ## need for recognize types and standard libraries
        python3
        clang
        tree-sitter
        typescript
        nodejs
        yarn
        pnpm
    ];
    neovimWrapped = pkgs.wrapNeovimUnstable
    inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.neovim
    {
        plugins = [
            (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
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
            ]))
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
                ++ runtimePackages;

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
