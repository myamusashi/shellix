{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.shellix.programs.nixos;
in {
  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = lib.mkDefault true;

      shellAliases = {
        kiss = "${pkgs.kitty}/bin/kitty + kitten ssh";
        icat = "${pkgs.kitty}/bin/kitten icat";
        ls = "${pkgs.eza}/bin/eza --icons";
      };

      shellInit = ''
        fish_add_path /home/myamusashi/.spicetify
        set -gx PATH $HOME/go/bin $HOME/.cargo/bin $HOME/.npm/bin $HOME/.local/bin $PATH
        set -gx EDITOR 'nvim -u $HOME/.config/nvim/init.lua'
        set -g fish_greeting

        	${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
        function imgcp
        	wl-copy < $argv[1]
        end
      '';
    };
  };
}
