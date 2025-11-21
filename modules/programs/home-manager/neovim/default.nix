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
        bun
        mesonlsp
        sqls
        docker-language-server
        fish-lsp
        ripgrep
        vscode-json-languageserver
        tree-sitter
        texlab
        texliveFull
        markdownlint-cli2
        live-server
        marksman
        bash-language-server
        shfmt
        prettierd
        stylua
        vscode-langservers-extracted
        lua-language-server
        kdePackages.qtdeclarative
        (callPackage ../../../../hosts/myamusashi/extra/qmlfmt.nix {})
      ];
    };
  };
}
