let
  matugen = import ./matugen.nix;
in {
  programs.wofi = {
    enable = true;
    style = ''
      window {
      	margin: 0px;
      	border: 1px solid ${matugen.primary};
      	background-color: ${matugen.background};
      }

      #input {
      	margin: 5px;
      	border: none;
      	color: ${matugen.on_primary};
      	background-color: ${matugen.on_background};
      }

      #inner-box {
      	margin: 5px;
      	border: none;
      	background-color: ${matugen.on_background};
      }

      #outer-box {
      	margin: 5px;
      	border: none;
      	background-color: ${matugen.on_background};
      }

      #scroll {
      	margin: 0px;
      	border: none;
      }

      #text {
      	margin: 5px;
      	border: none;
      	color: ${matugen.on_primary};
      }

      #entry:selected {
      	background-color: ${matugen.inverse_surface};
      }
    '';
    settings = {
      pre_display_exec = true;
      image_size = 128;
    };
  };
}
