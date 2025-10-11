{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.shellix.programs.home.neovim;
in {
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      plugins = with pkgs; [
        (tree-sitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      ];
      extraPackages = with pkgs; [
        alejandra
        lemminx
        svelte-language-server
        gopls
        pnpm_10
        yarn
        bun
        nixd
        nil
        gnumake
        mesonlsp
        sassc
        sqls
        dockerfile-language-server-nodejs
        jdt-language-server
        google-java-format
        vscode-langservers-extracted
        llvmPackages_19.clang-unwrapped # C stuff
        gcc14
        typescript-language-server
        sqls
        sass
        lua54Packages.luarocks_bootstrap
        stylua
        typescript
        nodejs-slim_22
        dockerfile-language-server-nodejs
        fish-lsp
        python312Packages.python-lsp-server
        pyright
        texlab
        kdePackages.qtdeclarative # Qml ls
        ripgrep
        vscode-json-languageserver
        qt6.qttools
        php
        phpactor
        tree-sitter
        texliveFull
        markdownlint-cli
        markdownlint-cli2
        live-server
        rust-analyzer
        marksman
        tailwindcss-language-server
        vscode-langservers-extracted # html, css, json, eslint
        bash-language-server
        shfmt # shell format
        prettierd # html, css, json formatting
        lua-language-server
      ];
    };
  };
}
