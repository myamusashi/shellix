{
  lib,
  config,
  ...
}: let
  cfg = config.shellix.programs.home.tofi;
  colors = config.shellix.matugen.colors.palette;
in {
  config = lib.mkIf cfg.enable {
    programs.tofi = {
      enable = true;
      settings = {
        font = "Liga SFMono Nerd Font";
        font-size = 20;
        font-features = "smcp, c2sc";
        font-variations = "wght 700";
        hint-font = false;

        text-color = colors.primary.hex;
        placeholder-color = "${colors.secondary.strip}cc";
        placeholder-background = "${colors.background.strip}cc";

        background-color = "${colors.background.strip}cc";
        outline-color = colors.on_primary.hex;
        border-color = colors.primary.hex;

        width = "100%";
        height = "100%";
        border-width = 0;
        outline-width = 0;
        padding-left = "35%";
        padding-top = "35%";
        result-spacing = 25;
        num-results = 5;
      };
    };
  };
}
