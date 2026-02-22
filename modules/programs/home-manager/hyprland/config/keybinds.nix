{config, ...}: let
    cfg = config.shellix.programs.home.hyprland;
    hy3_bind = [
        "$modalt, left, exec, hyprctl dispatch hy3:movefocus l"
        "$modalt, right, exec, hyprctl dispatch hy3:movefocus r"
        "$modalt, up, exec, hyprctl dispatch hy3:movefocus u"
        "$modalt, down, exec, hyprctl dispatch hy3:movefocus d"

        "SHIFT $modalt, G, exec, hyprctl dispatch hy3:makegroup tab"

        "$mod, left, exec, hyprctl dispatch hy3:movewindow l"
        "$mod, right, exec, hyprctl dispatch hy3:movewindow r"
        "$mod, up, exec, hyprctl dispatch hy3:movewindow u"
        "$mod, down, exec, hyprctl dispatch hy3:movewindow d"
    ];
    scrolling_bind = [
        "SHIFT CTRL, left, layoutmsg, movewindowto l"
        "SHIFT CTRL, right, layoutmsg, movewindowto r"
        "SHIFT CTRL, up, layoutmsg, movewindowto u"
        "SHIFT CTRL, down, layoutmsg, movewindowto d"

        "SHIFT $mod, left, layoutmsg, swapcol l"
        "SHIFT $mod, right, layoutmsg, swapcol r"

        "$mod CTRL, right, layoutmsg, move +col"
        "$mod CTRL, left, layoutmsg, move -col"

        "$modalt, A, layoutmsg, fit active"
        "SHIFT $modalt, A, layoutmsg, fit toend"

        "$modalt, left, movefocus, l"
        "$modalt, right, movefocus, r"
        "$modalt, up, movefocus, u"
        "$modalt, down, movefocus, d"
    ];
    default_bind = [
        "$mod, left, movewindow, l"
        "$mod, right, movewindow, r"
        "$mod, up, movewindow, u"
        "$mod, down, movewindow, d"

        "$modalt, left, movefocus, l"
        "$modalt, right, movefocus, r"
        "$modalt, up, movefocus, u"
        "$modalt, down, movefocus, d"
    ];

    finalKeybinds =
        if cfg.plugins.hy3.keybind
        then hy3_bind
        else default_bind;
in {
    bindm = [
        "$modalt, mouse:273, resizewindow"
        "$modalt, mouse:272, movewindow"
    ];

    binds = {drag_threshold = 10;};

    bind =
        [
            "$modalt, RETURN, exec, $term" # foot need
            "$modalt, F, exec, $browser" # zen need
            "$modalt, E, exec, $files" # yazi need
            "SHIFT $modalt, C, exec, $clipmanager" # cliphist need
            "SHIFT $modalt, D, exec, $record-panel"
            "$modalt, S, exec, hyprctl keyword monitorv2[eDP-1]:disabled 1"
            "$modalt, W, exec, $wallpaper-switcher"
            "$modalt CTRL, W, exec, $weather-panel"
            "$modalt, SPACE, exec, $launcher" # quickshell need
            "$mod, W, exec, $dashboard" # quickshell need
            "$modalt, B, exec, $bar" # quickshell need
            "$modalt, D, exec, $powermenu" # quickshell need
            "$modalt, L, exec, $lockscreen" # quickshell need
            "$modalt, T, exec, telegram-desktop"
            "$modalt, TAB, global, quickshell:overview"
            "SHIFT $modalt, P, exec, $colorpick"
            "$mod, S, exec, $screencapture"
            "SHIFT $modalt, TAB, togglefloating"
            "$modalt, Q, killactive"
            "$modalt, P, pseudo"
            "SHIFT $modalt, RETURN, fullscreen"
            "SuperShift, S, layoutmsg, togglesplit"
            # Change Workspace Mode
            "SuperShift, F, workspaceopt, allfloat"
            "SuperShift, P, workspaceopt, allpseudo"
            "$mod, Tab, cyclenext"
            "$mod, Tab, bringactivetotop"
            # Resize
            "$modalt CTRL, left, resizeactive, -20 0"
            "$modalt CTRL, right, resizeactive, 20 0"
            "$modalt CTRL, up, resizeactive, 0 -20"
            "$modalt CTRL, down, resizeactive, 0 20"
            # Workspace navigation
            "SHIFT $modalt, up, workspace, e+1"
            "SHIFT $modalt, down, workspace, e-1"
            "SHIFT $modalt, right, workspace, r+1"
            "SHIFT $modalt, left, workspace, r-1"
            "$modalt, mouse_down, workspace, e+1"
            "$modalt, mouse_up, workspace, e-1"
            # Media keys
            ", XF86AudioStop, exec, playerctl play-pause"
            ", XF86AudioPrev, exec, playerctl previous"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioLowerVolume,exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86AudioRaiseVolume,exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            "$modalt, TAB, exec, hyprctl dispatch overview:toggle"
        ]
        ++ scrolling_bind
        ++ (
            # workspaces - bind $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList
            (i: let ws = i + 1; in ["$mod, ${toString ws}, movetoworkspace, ${toString ws}"])
            9)
        );
}
