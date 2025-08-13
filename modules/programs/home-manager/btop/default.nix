{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.shellix.programs.home;
  color = config.shellix.matugen.colors.palette;
in {
  config = mkIf cfg.enable {
    home.file = {
      ".config/btop/themes/shellix.themes" = {
        enable = true;
        text = ''
          theme[main_bg]="${color.background.hex}"
          theme[main_fg]="${color.on_background.hex}"
          theme[title]="${color.on_surface.hex}"
          theme[hi_fg]="${color.surface_tint.hex}"
          theme[selected_bg]="${color.surface_container.hex}"
          theme[selected_fg]="${color.surface_tint.hex}"
          theme[inactive_fg]="${color.on_tertiary.hex}"

          theme[graph_text]="${color.tertiary.hex}"
          theme[proc_misc]="${color.tertiary.hex}"
          theme[cpu_box]="${color.secondary.hex}"
          theme[mem_box]="${color.on_surface.hex}"
          theme[net_box]="${color.surface_tint.hex}"
          theme[proc_box]="${color.on_secondary_container.hex}"

          theme[div_line]="${color.outline.hex}"

          theme[temp_start]="${color.on_tertiary_container.hex}"
          theme[temp_mid]="${color.on_surface.hex}"
          theme[temp_end]="${color.inverse_primary.hex}"

          theme[cpu_start]="${color.on_tertiary_container.hex}"
          theme[cpu_mid]="${color.secondary.hex}"
          theme[cpu_end]="${color.primary.hex}"

          theme[free_start]="${color.secondary.hex}"
          theme[free_mid]="${color.primary.hex}"
          theme[free_end]="${color.on_secondary_container.hex}"

          theme[cached_start]="${color.secondary.hex}"
          theme[cached_mid]="${color.on_secondary_container.hex}"
          theme[cached_end]="${color.primary.hex}"

          theme[available_start]="${color.on_tertiary_container.hex}"
          theme[available_mid]="${color.surface_tint.hex}"
          theme[available_end]="${color.inverse_primary.hex}"

          theme[used_start]="${color.on_surface.hex}"
          theme[used_mid]="${color.tertiary.hex}"
          theme[used_end]="${color.on_surface.hex}"

          theme[download_start]="${color.on_tertiary_container.hex}"
          theme[download_mid]="${color.surface_tint.hex}"
          theme[download_end]="${color.inverse_primary.hex}"

          theme[upload_start]="${color.on_surface.hex}"
          theme[upload_mid]="${color.tertiary.hex}"
          theme[upload_end]="${color.on_surface.hex}"

          theme[process_start]="${color.secondary.hex}"
          theme[process_mid]="${color.on_secondary_container.hex}"
          theme[process_end]="${color.primary.hex}"
        '';
      };
    };

    programs.btop = {
      enable = mkDefault true;

      settings = {
        color_theme = "shellix";
        theme_background = false;
        truecolor = false;
        force_tty = false;
        presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
        vim_keys = false;
        rounded_corners = false;
        graph_symbol = "braille";
        graph_symbol_cpu = "default";
        graph_symbol_gpu = "default";
        graph_symbol_mem = "default";
        graph_symbol_net = "default";
        graph_symbol_proc = "default";
        shown_boxes = "cpu mem net proc";
        update_ms = 1000;
        proc_sorting = "user";
        proc_reversed = true;
        proc_tree = false;
        proc_colors = true;
        proc_gradient = true;
        proc_per_core = true;
        proc_mem_bytes = true;
        proc_cpu_graphs = true;
        proc_info_smaps = false;
        proc_left = false;
        proc_filter_kernel = false;
        proc_aggregate = false;
        cpu_graph_upper = "Auto";
        cpu_graph_lower = "idle";
        show_gpu_info = "Auto";
        cpu_invert_lower = true;
        cpu_single_graph = false;
        cpu_bottom = false;
        show_uptime = true;
        check_temp = true;
        cpu_sensor = "Auto";
        show_coretemp = false;
        cpu_core_map = "";
        temp_scale = "celsius";
        base_10_sizes = false;
        show_cpu_freq = true;
        clock_format = "%X";
        background_update = true;
        custom_cpu_name = "sigma";
        disks_filter = "";
        mem_graphs = true;
        mem_below_net = false;
        zfs_arc_cached = true;
        show_swap = true;
        swap_disk = true;
        show_disks = true;
        only_physical = true;
        use_fstab = true;
        zfs_hide_datasets = false;
        disk_free_priv = false;
        show_io_stat = true;
        io_mode = true;
        io_graph_combined = true;
        io_graph_speeds = "";
        net_download = 100;
        net_upload = 100;
        net_auto = true;
        net_sync = true;
        net_iface = "";
        show_battery = true;
        selected_battery = "Auto";
        show_battery_watts = true;
        log_level = "WARNING";
        nvml_measure_pcie_speeds = true;
        gpu_mirror_graph = true;
      };
    };
  };
}
