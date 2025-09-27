{config, ...}: let
  colors = config.shellix.matugen.colors.palette;
in {
  enable = true;
  text = ''
    [ColorEffects:Disabled]
    Color=${colors.surface_variant.rgb-strip}
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.65
    ContrastEffect=1
    IntensityAmount=0.1
    IntensityEffect=2

    [ColorEffects:Inactive]
    ChangeSelectionColor=true
    Color=${colors.outline.rgb-strip}
    ColorAmount=0.025
    ColorEffect=2
    ContrastAmount=0.1
    ContrastEffect=2
    Enable=false
    IntensityAmount=0
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=${colors.surface_container_high.rgb-strip}
    BackgroundNormal=${colors.surface_container.rgb-strip}
    DecorationFocus=${colors.primary.rgb-strip}
    DecorationHover=${colors.primary.rgb-strip}
    ForegroundActive=${colors.primary.rgb-strip}
    ForegroundInactive=${colors.outline.rgb-strip}
    ForegroundLink=${colors.primary.rgb-strip}
    ForegroundNegative=${colors.error.rgb-strip}
    ForegroundNeutral=${colors.tertiary.rgb-strip}
    ForegroundNormal=${colors.on_surface.rgb-strip}
    ForegroundPositive=${colors.secondary.rgb-strip}
    ForegroundVisited=${colors.secondary.rgb-strip}

    [Colors:Complementary]
    BackgroundAlternate=${colors.surface_container_high.rgb-strip}
    BackgroundNormal=${colors.surface_container_low.rgb-strip}
    DecorationFocus=${colors.primary.rgb-strip}
    DecorationHover=${colors.primary.rgb-strip}
    ForegroundActive=${colors.primary.rgb-strip}
    ForegroundInactive=${colors.outline.rgb-strip}
    ForegroundLink=${colors.primary.rgb-strip}
    ForegroundNegative=${colors.error.rgb-strip}
    ForegroundNeutral=${colors.tertiary.rgb-strip}
    ForegroundNormal=${colors.on_surface.rgb-strip}
    ForegroundPositive=${colors.secondary.rgb-strip}
    ForegroundVisited=${colors.secondary.rgb-strip}

    [Colors:Header]
    BackgroundAlternate=${colors.surface_container_low.rgb-strip}
    BackgroundNormal=${colors.surface_container.rgb-strip}
    DecorationFocus=${colors.primary.rgb-strip}
    DecorationHover=${colors.primary.rgb-strip}
    ForegroundActive=${colors.primary.rgb-strip}
    ForegroundInactive=${colors.outline.rgb-strip}
    ForegroundLink=${colors.primary.rgb-strip}
    ForegroundNegative=${colors.error.rgb-strip}
    ForegroundNeutral=${colors.tertiary.rgb-strip}
    ForegroundNormal=${colors.on_surface.rgb-strip}
    ForegroundPositive=${colors.secondary.rgb-strip}
    ForegroundVisited=${colors.secondary.rgb-strip}

    [Colors:Header][Inactive]
    BackgroundAlternate=${colors.surface_container.rgb-strip}
    BackgroundNormal=${colors.surface_container_low.rgb-strip}
    DecorationFocus=${colors.primary.rgb-strip}
    DecorationHover=${colors.primary.rgb-strip}
    ForegroundActive=${colors.primary.rgb-strip}
    ForegroundInactive=${colors.outline.rgb-strip}
    ForegroundLink=${colors.primary.rgb-strip}
    ForegroundNegative=${colors.error.rgb-strip}
    ForegroundNeutral=${colors.tertiary.rgb-strip}
    ForegroundNormal=${colors.on_surface.rgb-strip}
    ForegroundPositive=${colors.secondary.rgb-strip}
    ForegroundVisited=${colors.secondary.rgb-strip}

    [Colors:Selection]
    BackgroundAlternate=${colors.primary_container.rgb-strip}
    BackgroundNormal=${colors.primary.rgb-strip}
    DecorationFocus=${colors.primary.rgb-strip}
    DecorationHover=${colors.primary.rgb-strip}
    ForegroundActive=${colors.on_primary.rgb-strip}
    ForegroundInactive=${colors.outline.rgb-strip}
    ForegroundLink=${colors.tertiary.rgb-strip}
    ForegroundNegative=${colors.error_container.rgb-strip}
    ForegroundNeutral=${colors.tertiary_container.rgb-strip}
    ForegroundNormal=${colors.on_primary.rgb-strip}
    ForegroundPositive=${colors.secondary_container.rgb-strip}
    ForegroundVisited=${colors.secondary.rgb-strip}

    [Colors:Tooltip]
    BackgroundAlternate=${colors.surface_container_low.rgb-strip}
    BackgroundNormal=${colors.surface_container.rgb-strip}
    DecorationFocus=${colors.primary.rgb-strip}
    DecorationHover=${colors.primary.rgb-strip}
    ForegroundActive=${colors.primary.rgb-strip}
    ForegroundInactive=${colors.outline.rgb-strip}
    ForegroundLink=${colors.primary.rgb-strip}
    ForegroundNegative=${colors.error.rgb-strip}
    ForegroundNeutral=${colors.tertiary.rgb-strip}
    ForegroundNormal=${colors.on_surface.rgb-strip}
    ForegroundPositive=${colors.secondary.rgb-strip}
    ForegroundVisited=${colors.secondary.rgb-strip}

    [Colors:View]
    BackgroundAlternate=${colors.surface_container_low.rgb-strip}
    BackgroundNormal=${colors.surface.rgb-strip}
    DecorationFocus=${colors.primary.rgb-strip}
    DecorationHover=${colors.primary.rgb-strip}
    ForegroundActive=${colors.primary.rgb-strip}
    ForegroundInactive=${colors.outline.rgb-strip}
    ForegroundLink=${colors.primary.rgb-strip}
    ForegroundNegative=${colors.error.rgb-strip}
    ForegroundNeutral=${colors.tertiary.rgb-strip}
    ForegroundNormal=${colors.on_surface.rgb-strip}
    ForegroundPositive=${colors.secondary.rgb-strip}
    ForegroundVisited=${colors.secondary.rgb-strip}

    [Colors:Window]
    BackgroundAlternate=${colors.surface_container.rgb-strip}
    BackgroundNormal=${colors.surface_container_low.rgb-strip}
    DecorationFocus=${colors.primary.rgb-strip}
    DecorationHover=${colors.primary.rgb-strip}
    ForegroundActive=${colors.primary.rgb-strip}
    ForegroundInactive=${colors.outline.rgb-strip}
    ForegroundLink=${colors.primary.rgb-strip}
    ForegroundNegative=${colors.error.rgb-strip}
    ForegroundNeutral=${colors.tertiary.rgb-strip}
    ForegroundNormal=${colors.on_surface.rgb-strip}
    ForegroundPositive=${colors.secondary.rgb-strip}
    ForegroundVisited=${colors.secondary.rgb-strip}

    [General]
    ColorScheme=Shell
    Name=Shell
    shadeSortColumn=true

    [KDE]
    contrast=4

    [WM]
    activeBackground=${colors.surface_container.rgb-strip}
    activeBlend=${colors.on_surface.rgb-strip}
    activeForeground=${colors.on_surface.rgb-strip}
    inactiveBackground=${colors.surface_container_low.rgb-strip}
    inactiveBlend=${colors.outline.rgb-strip}
    inactiveForeground=${colors.outline.rgb-strip}
  '';
}
