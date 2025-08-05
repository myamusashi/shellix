let
  matugen = import ./matugen.nix;
in {
  programs.tofi = {
    enable = true;
    settings = {
      font = "Hack";
      font-size = 20;
      font-features = "smcp, c2sc";
      font-variations = "wght 700";
      hint-font = false;

      text-color = matugen.primary;
      placeholder-color = "${matugen.secondary}cc";
      placeholder-background = "${matugen.background}cc";

      background-color = "${matugen.background}cc";
      outline-color = matugen.on_primary;
      border-color = matugen.primary;

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
}
