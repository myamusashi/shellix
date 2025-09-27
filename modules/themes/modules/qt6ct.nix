{config, ...}: let
  colors = config.shellix.matugen.colors.palette;
in {
  enable = true;
  text = ''
    [ColorScheme]
    active_colors=${colors.on_background.hex}, ${colors.surface.hex}, #ffffff, ${colors.outline.hex}, ${colors.outline_variant.hex}, ${colors.surface_variant.hex}, ${colors.on_background.hex}, #ffffff, ${colors.on_surface.hex}, ${colors.background.hex}, ${colors.background.hex}, ${colors.shadow.hex}, ${colors.primary_container.hex}, ${colors.on_primary_container.hex}, ${colors.secondary.hex}, ${colors.primary.hex}, ${colors.surface.hex}, ${colors.scrim.hex}, ${colors.surface.hex}, ${colors.on_surface.hex}, ${colors.secondary.hex}
    disabled_colors=${colors.on_background.hex}, ${colors.surface.hex}, #ffffff, ${colors.outline.hex}, ${colors.outline_variant.hex}, ${colors.surface_variant.hex}, ${colors.on_background.hex}, #ffffff, ${colors.on_surface.hex}, ${colors.background.hex}, ${colors.background.hex}, ${colors.shadow.hex}, ${colors.primary_container.hex}, ${colors.on_primary_container.hex}, ${colors.secondary.hex}, ${colors.primary.hex}, ${colors.surface.hex}, ${colors.scrim.hex}, ${colors.surface.hex}, ${colors.on_surface.hex}, ${colors.secondary.hex}
    inactive_colors=${colors.on_background.hex}, ${colors.surface.hex}, #ffffff, ${colors.outline.hex}, ${colors.outline_variant.hex}, ${colors.surface_variant.hex}, ${colors.on_background.hex}, #ffffff, ${colors.on_surface.hex}, ${colors.background.hex}, ${colors.background.hex}, ${colors.shadow.hex}, ${colors.primary_container.hex}, ${colors.on_primary_container.hex}, ${colors.secondary.hex}, ${colors.primary.hex}, ${colors.surface.hex}, ${colors.scrim.hex}, ${colors.surface.hex}, ${colors.on_surface.hex}, ${colors.secondary.hex}
  '';
}
