{config}: let
  color = config.shellix.matugen.colors.palette;
in {
  text = ''
    theme[main_bg]=${color.background.hex}
    theme[main_fg]=${color.on_background.hex}
    theme[title]=${color.on_surface.hex}
    theme[hi_fg]=${color.surface_tint.hex}
    theme[selected_bg]=${color.surface_container.hex}
    theme[selected_fg]=${color.surface_tint.hex}
    theme[inactive_fg]=${color.on_tertiary.hex}

    theme[graph_text]=${color.tertiary.hex}
    theme[proc_misc]=${color.tertiary.hex}
    theme[cpu_box]=${color.secondary.hex}
    theme[mem_box]=${color.on_surface.hex}
    theme[net_box]=${color.surface_tint.hex}
    theme[proc_box]=${color.on_secondary_container.hex}

    theme[div_line]=${color.outline.hex}

    theme[temp_start]=${color.on_tertiary_container.hex}
    theme[temp_mid]=${color.on_surface.hex}
    theme[temp_end]=${color.inverse_primary.hex}

    theme[cpu_start]=${color.on_tertiary_container.hex}
    theme[cpu_mid]=${color.secondary.hex}
    theme[cpu_end]=${color.primary.hex}

    theme[free_start]=${color.secondary.hex}
    theme[free_mid]=${color.primary.hex}
    theme[free_end]=${color.on_secondary_container.hex}

    theme[cached_start]=${color.secondary.hex}
    theme[cached_mid]=${color.on_secondary_container.hex}
    theme[cached_end]=${color.primary.hex}

    theme[available_start]=${color.on_tertiary_container.hex}
    theme[available_mid]=${color.surface_tint.hex}
    theme[available_end]=${color.inverse_primary.hex}

    theme[used_start]=${color.on_surface.hex}
    theme[used_mid]=${color.tertiary.hex}
    theme[used_end]=${color.on_surface.hex}

    theme[download_start]=${color.on_tertiary_container.hex}
    theme[download_mid]=${color.surface_tint.hex}
    theme[download_end]=${color.inverse_primary.hex}

    theme[upload_start]=${color.on_surface.hex}
    theme[upload_mid]=${color.tertiary.hex}
    theme[upload_end]=${color.on_surface.hex}

    theme[process_start]=${color.secondary.hex}
    theme[process_mid]=${color.on_secondary_container.hex}
    theme[process_end]=${color.primary.hex}
  '';
}
