{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.shellix.programs.spicetify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in {
  imports = [inputs.spicetify-nix.nixosModules.default];

  options.shellix.programs.spicetify = {
    enable = lib.mkEnableOption "Enable Spicetify spotify mod applications";
  };

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
