{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.btop;
    configBtop = ''
        background_update = True
        base_10_sizes = False
        check_temp = True
        clock_format = "%X"
        color_theme = "shellix"
        cpu_bottom = False
        cpu_core_map = ""
        cpu_graph_lower = "idle"
        cpu_graph_upper = "Auto"
        cpu_invert_lower = True
        cpu_sensor = "Auto"
        cpu_single_graph = False
        custom_cpu_name = "sigma"
        disk_free_priv = False
        disks_filter = ""
        force_tty = False
        gpu_mirror_graph = True
        graph_symbol = "braille"
        graph_symbol_cpu = "default"
        graph_symbol_gpu = "default"
        graph_symbol_mem = "default"
        graph_symbol_net = "default"
        graph_symbol_proc = "default"
        io_graph_combined = True
        io_graph_speeds = ""
        io_mode = True
        log_level = "WARNING"
        mem_below_net = False
        mem_graphs = True
        net_auto = True
        net_download = 100
        net_iface = ""
        net_sync = True
        net_upload = 100
        nvml_measure_pcie_speeds = True
        only_physical = True
        presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty"
        proc_aggregate = False
        proc_colors = True
        proc_cpu_graphs = True
        proc_filter_kernel = False
        proc_gradient = True
        proc_info_smaps = False
        proc_left = False
        proc_mem_bytes = True
        proc_per_core = True
        proc_reversed = True
        proc_sorting = "user"
        proc_tree = False
        rounded_corners = False
        selected_battery = "Auto"
        show_battery = True
        show_battery_watts = True
        show_coretemp = False
        show_cpu_freq = True
        show_disks = True
        show_gpu_info = "Auto"
        show_io_stat = True
        show_swap = True
        show_uptime = True
        shown_boxes = "cpu mem net proc"
        swap_disk = True
        temp_scale = "celsius"
        theme_background = False
        truecolor = False
        update_ms = 1000
        use_fstab = True
        vim_keys = False
        zfs_arc_cached = True
        zfs_hide_datasets = False
    '';
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.btop];
        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/fastfetch 0755 myamusashi users - -"
            "L+ %h/.config/btop/btop.conf - - - - ${pkgs.writeText "btop-config" configBtop}"
        ];
    };
}
