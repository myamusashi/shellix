{config, ...}: let
  color = config.shellix.matugen.colors.palette;
in {
  enable = true;
  text = ''
    themes {
      	shellix {
      		text_unselected {
      			base "${color.on_background.hex}"
      			background "${color.background.hex}"
      			emphasis_0 "${color.primary.hex}"
      			emphasis_1 "${color.secondary.hex}"
      			emphasis_2 "${color.tertiary.hex}"
      			emphasis_3 "${color.on_surface_variant.hex}"
      		}
      		text_selected {
      			base "${color.background.hex}"
      			background "${color.tertiary.hex}"
      			emphasis_0 "${color.primary.hex}"
      			emphasis_1 "${color.secondary.hex}"
      			emphasis_2 "${color.tertiary.hex}"
      			emphasis_3 "${color.on_surface_variant.hex}"
      		}
      		ribbon_selected {
      			base "${color.background.hex}"
      			background "${color.tertiary.hex}"
      			emphasis_0 "${color.error.hex}"
      			emphasis_1 "${color.primary.hex}"
      			emphasis_2 "${color.on_surface_variant.hex}"
      			emphasis_3 "${color.secondary.hex}"
      		}
      		ribbon_unselected {
      			base "${color.background.hex}"
      			background "${color.on_background.hex}"
      			emphasis_0 "${color.error.hex}"
      			emphasis_1 "${color.on_background.hex}"
      			emphasis_2 "${color.secondary.hex}"
      			emphasis_3 "${color.on_surface_variant.hex}"
      		}
      		table_title {
      			base "${color.tertiary.hex}"
      			background 0
      			emphasis_0 "${color.primary.hex}"
      			emphasis_1 "${color.secondary.hex}"
      			emphasis_2 "${color.tertiary.hex}"
      			emphasis_3 "${color.on_surface_variant.hex}"
      		}
      		table_cell_selected {
      			base "${color.background.hex}"
      			background "${color.tertiary.hex}"
      			emphasis_0 "${color.primary.hex}"
      			emphasis_1 "${color.secondary.hex}"
      			emphasis_2 "${color.tertiary.hex}"
      			emphasis_3 "${color.on_surface_variant.hex}"
      		}
      		table_cell_unselected {
      			base "${color.on_background.hex}"
      			background "${color.background.hex}"
      			emphasis_0 "${color.primary.hex}"
      			emphasis_1 "${color.secondary.hex}"
      			emphasis_2 "${color.tertiary.hex}"
      			emphasis_3 "${color.on_surface_variant.hex}"
      		}
      		list_selected {
      			base "${color.background.hex}"
      			background "${color.tertiary.hex}"
      			emphasis_0 "${color.primary.hex}"
      			emphasis_1 "${color.secondary.hex}"
      			emphasis_2 "${color.tertiary.hex}"
      			emphasis_3 "${color.on_surface_variant.hex}"
      		}
      		list_unselected {
      			base "${color.on_background.hex}"
      			background "${color.background.hex}"
      			emphasis_0 "${color.primary.hex}"
      			emphasis_1 "${color.secondary.hex}"
      			emphasis_2 "${color.tertiary.hex}"
      			emphasis_3 "${color.on_surface_variant.hex}"
      		}
      		frame_selected {
      			base "${color.tertiary.hex}"
      			background 0
      			emphasis_0 "${color.primary.hex}"
      			emphasis_1 "${color.secondary.hex}"
      			emphasis_2 "${color.on_surface_variant.hex}"
      			emphasis_3 0
      		}
      		frame_highlight {
      			base "${color.primary.hex}"
      			background 0
      			emphasis_0 "${color.on_surface_variant.hex}"
      			emphasis_1 "${color.primary.hex}"
      			emphasis_2 "${color.primary.hex}"
      			emphasis_3 "${color.primary.hex}"
      		}
      		exit_code_success {
      			base "${color.tertiary.hex}"
      			background 0
      			emphasis_0 "${color.secondary.hex}"
      			emphasis_1 "${color.background.hex}"
      			emphasis_2 "${color.on_surface_variant.hex}"
      			emphasis_3 "${color.primary.hex}"
      		}
      		exit_code_error {
      			base "${color.error.hex}"
      			background 0
      			emphasis_0 "${color.primary.hex}"
      			emphasis_1 0
      			emphasis_2 0
      			emphasis_3 0
      		}
      		multiplayer_user_colors {
      			player_1 "${color.on_surface_variant.hex}"
      			player_2 "${color.primary.hex}"
      			player_3 0
      			player_4 "${color.tertiary.hex}"
      			player_5 "${color.secondary.hex}"
      			player_6 0
      			player_7 "${color.error.hex}"
      			player_8 0
      			player_9 0
      			player_10 0
      		}
      	}
      }
  '';
}
