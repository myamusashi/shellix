{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.home;
  colors = config.shellix.matugen.colors.palette;
in {
  config = lib.mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      style = ''
        window {
        	margin: 0px;
        	border: 1px solid ${colors.primary.hex};
        	background-color: ${colors.background.hex};
        }

        #input {
        	margin: 5px;
        	border: none;
        	color: ${colors.on_primary.hex};
        	background-color: ${colors.on_background.hex};
        }

        #inner-box {
        	margin: 5px;
        	border: none;
        	background-color: ${colors.on_background.hex};
        }

        #outer-box {
        	margin: 5px;
        	border: none;
        	background-color: ${colors.on_background.hex};
        }

        #scroll {
        	margin: 0px;
        	border: none;
        }

        #text {
        	margin: 5px;
        	border: none;
        	color: ${colors.on_primary.hex};
        }

        #entry:selected {
        	background-color: ${colors.inverse_surface.hex};
        }
      '';
      settings = {
        pre_display_exec = true;
        image_size = 128;
      };
    };
  };
}
