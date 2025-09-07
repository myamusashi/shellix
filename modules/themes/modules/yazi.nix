{config, ...}: let
  color = config.shellix.matugen.colors.palette;
in {
  enable = true;
  text = ''
    # : Manager [[[

    [manager]
    cwd = { fg = "${color.on_surface.hex}" }

    # Tab
    tab_active = { fg = "${color.on_primary.hex}", bg = "${color.primary.hex}", bold = true }
    tab_inactive = { fg = "${color.primary_fixed.hex}", bg = "${color.on_primary_fixed.hex}" }
    tab_width = 1

    # Find
    find_keyword = { fg = "${color.error.hex}", bold = true, italic = true, underline = true }
    find_position = { fg = "${color.error.hex}", bold = true, italic = true }

    # Marker
    marker_copied = { fg = "${color.tertiary_fixed.hex} | auto_lightness: 20.0", bg = "${color.tertiary_fixed.hex} | auto_lightness: 20.0" }
    marker_cut = { fg = "${color.tertiary_fixed.hex}", bg = "${color.tertiary_fixed.hex}" }
    marker_marked = { fg = "${color.error.hex}", bg = "${color.error.hex}" }
    marker_selected = { fg = "${color.tertiary.hex}", bg = "${color.tertiary.hex}" }

    # Count
    count_copied = { fg = "${color.on_tertiary_fixed.hex}", bg = "${color.tertiary_fixed.hex}" }
    count_cut = { fg = "${color.on_tertiary_fixed.hex}", bg = "${color.tertiary_fixed.hex}" }
    count_selected = { fg = "${color.on_primary.hex}", bg = "${color.tertiary.hex}" }

    # Border
    border_symbol = "│"
    border_style  = { fg = "${color.surface_tint.hex}" }

    # : ]]]


    # : Status [[[

    [status]
    separator_open = "🭁"
    separator_close = "🭠"
    separator_style = { bg = "${color.on_primary.hex}", fg = "#F4A261" }

    [mode]
    # Mode
    normal_main = { bg = "${color.primary.hex}", fg = "${color.on_primary.hex}", bold = true }
    normal_alt  = { bg = "${color.surface_variant.hex}", fg = "${color.on_surface_variant.hex}" }

    # Select mode
    select_main = { bg = "${color.secondary.hex}", fg = "${color.on_secondary.hex}", bold = true }
    select_alt  = { bg = "${color.surface_variant.hex}", fg = "${color.on_surface_variant.hex}" }

    # Unset mode
    unset_main = { bg = "${color.tertiary.hex}", fg = "${color.on_tertiary.hex}", bold = true }
    unset_alt  = { bg = "${color.surface_variant.hex}", fg = "${color.on_surface_variant.hex}" }

    # Progress
    progress_label = { bold = true }
    progress_normal = { fg = "${color.primary.hex}", bg = "${color.surface_bright.hex}" }
    progress_error = { fg = "${color.error.hex}", bg = "${color.surface_bright.hex}" }

    # Permissions
    permissions_t = { fg = "${color.secondary.hex} | auto_lightness: 30.0" }
    permissions_w = { fg = "${color.tertiary.hex} | auto_lightness: 30.0" }
    permissions_x = { fg = "${color.error.hex} | auto_lightness: 30.0" }
    permissions_r = { fg = "${color.tertiary_fixed.hex} | auto_lightness: 30.0" }
    permissions_s = { fg = "${color.primary_fixed.hex} | auto_lightness: 30.0" }

    # : ]]]


    # : Select [[[

    [select]
    border = { fg = "${color.primary.hex}" }
    active = { fg = "${color.tertiary.hex}", bold = true }
    inactive = {}

    # : ]]]


    # : Input [[[

    [input]
    border = { fg = "${color.primary.hex}" }
    value = { fg = "${color.on_surface.hex}" }

    # : ]]]


    # : Completion [[[

    [completion]
    border = { fg = "${color.primary.hex}", bg = "${color.on_primary.hex}" }

    # : ]]]


    # : Tasks [[[

    [tasks]
    border = { fg = "${color.primary.hex}" }
    title = {}
    hovered = { fg = "${color.tertiary_fixed.hex}", underline = true }

    # : ]]]


    # : Which [[[

    [which]
    cols = 3
    mask = { bg = "${color.surface_bright.hex}" }
    cand = { fg = "${color.primary.hex}" }
    rest = { fg = "${color.on_primary.hex}" }
    desc = { fg = "${color.on_surface.hex}" }
    separator = " ▶ "
    separator_style = { fg = "${color.on_surface.hex}" }

    # : ]]]


    # : Help [[[

    [help]
    on = { fg = "${color.on_surface.hex}" }
    run = { fg = "${color.on_surface.hex}" }
    footer = { fg = "${color.on_secondary.hex}", bg = "${color.secondary.hex}" }

    # : ]]]


    # : Notify [[[

    [notify]
    title_info = { fg = "${color.tertiary.hex}" }
    title_warn = { fg = "${color.primary.hex}" }
    title_error = { fg = "${color.error.hex}" }

    # : ]]]


    # : File-specific styles [[[

    [filetype]

    rules = [
        # Images
        { mime = "image/*", fg = "#94e2d5" },

        # Media
        { mime = "{audio,video}/*", fg = "#f9e2af" },

        # Archives
        { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "#f5c2e7" },

        # Documents
        { mime = "application/{pdf,doc,rtf}", fg = "#a6e3a1" },

        # Special files
        { name = "*", is = "orphan", bg = "${color.error_container.hex}" },
        { name = "*", is = "exec", fg = "${color.on_error_container.hex}" },

        # Fallback
        { name = "*", fg = "${color.on_surface.hex}" },
        { name = "*/", fg = "${color.surface_tint.hex}" },
    ]

    # : ]]]
  '';
}
