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
      plugins = with pkgs; [
        (tree-sitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      ];
      extraPackages = with pkgs; [
        bun
        mesonlsp
        sqls
        docker-language-server
        fish-lsp
        ripgrep
        vscode-json-languageserver
        tree-sitter
        gnumake
        pnpm
        yarn
        markdownlint-cli2
        live-server
        marksman
        arduino-language-server
        arduino-cli
        llvm
        bash-language-server
        shfmt
        prettierd
        stylua
        vscode-langservers-extracted
        lua-language-server
        kdePackages.qtdeclarative
      ];
    };
  };
}
