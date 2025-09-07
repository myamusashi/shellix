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
        img = "${pkgs.libsixel}/bin/img2sixel";
        icat = "${pkgs.kitty}/bin/kitten icat";
        ls = "${pkgs.eza}/bin/eza --icons";
        lla = "${pkgs.eza}/bin/eza -a --icons";
        setWal = "${pkgs.quickshell}/bin/qs -c lock ipc call img set $argv[1]";
      };

      shellInit = ''
            fish_add_path /home/myamusashi/.spicetify
            set -gx PATH $HOME/go/bin $HOME/.cargo/bin $HOME/.npm/bin $HOME/.local/bin $PATH
            set -gx EDITOR 'nvim -u $HOME/.config/nvim/init.lua'
            set -g fish_greeting

            ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
            function imgcp
                ${pkgs.wl-clipboard}/bin/wl-copy <$argv[1]
            end
        function fontlist
        	fc-list --format='%{family}\\n' | ${pkgs.ripgrep}/bin/rg "$argv[1]"
        end
      '';
    };
  };
}
