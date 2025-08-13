{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.shellix.programs.home;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in {
  imports = [inputs.spicetify-nix.homeManagerModules.spicetify];

  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        hidePodcasts
        shuffle
        adblockify
        betterGenres
        copyToClipboard
      ];
      theme = spicePkgs.themes.hazy;
      enabledCustomApps = with spicePkgs.apps; [
        lyricsPlus
      ];
    };
  };
}
