{config, ...}: let
  vars = import ./variable.nix {inherit config;};
in {
  bindm = with vars; [
    "${modalt}, mouse:273, resizewindow"
    "${modalt}, mouse:272, movewindow"
  ];

  binds = {drag_threshold = 10;};

  bind = with vars;
    [
      "${modalt}, RETURN, exec, ${term}" # foot need
      "${modalt}, F, exec, ${browser}" # zen need
      "${modalt}, E, exec, ${files}" # yazi need
      "SHIFT ${modalt}, C, exec, ${clipmanager}" # cliphist need
      "SHIFT ${modalt}, D, exec, ${discord}" # vesktop need
      "${modalt}, SPACE, exec, ${launcher}" # quickshell need
      "${modalt}, S, exec, ${spotify}"
      "${mod}, W, exec, ${dashboard}" # quickshell need
      "${modalt}, B, exec, ${bar}" # quickshell need
      "${modalt}, D, exec, ${powermenu}" # quickshell need
      "${modalt}, L, exec, ${lockscreen}" # quickshell need
      "${modalt}, T, exec, telegram-desktop"
      "${modalt}, TAB, global, quickshell:overview"
      "SHIFT ${modalt}, P, exec, ${colorpick}"
      "${mod}, S, exec, ${screencapture}"
      "SHIFT ${modalt}, TAB, togglefloating"
      "${modalt}, Q, killactive"
      "${modalt}, P, pseudo"
      "SHIFT ${modalt}, RETURN, fullscreen"
      "SuperShift, S, layoutmsg, togglesplit"
      # Change Workspace Mode
      "SuperShift, F, workspaceopt, allfloat"
      "SuperShift, P, workspaceopt, allpseudo"
      "${mod}, Tab, cyclenext"
      "${mod}, Tab, bringactivetotop"
      "${modalt}, left, movefocus, l"
      "${modalt}, right, movefocus, r"
      "${modalt}, up, movefocus, u"
      "${modalt}, down, movefocus, d"
      # hy3
      "${mod} CTRL, left, exec, hyprctl dispatch hy3:movefocus l"
      "${mod} CTRL, right, exec, hyprctl dispatch hy3:movefocus r"
      "${mod} CTRL, up, exec, hyprctl dispatch hy3:movefocus u"
      "${mod} CTRL, down, exec, hyprctl dispatch hy3:movefocus d"
      "SHIFT ${modalt}, G, exec, hyprctl dispatch hy3:makegroup tab"
      "${mod}, left, exec, hyprctl dispatch hy3:movewindow l"
      "${mod}, right, exec, hyprctl dispatch hy3:movewindow r"
      "${mod}, up, exec, hyprctl dispatch hy3:movewindow u"
      "${mod}, down, exec, hyprctl dispatch hy3:movewindow d"
      # Resize
      "${modalt} CTRL, left, resizeactive, -20 0"
      "${modalt} CTRL, right, resizeactive, 20 0"
      "${modalt} CTRL, up, resizeactive, 0 -20"
      "${modalt} CTRL, down, resizeactive, 0 20"
      # Workspace navigation
      "SHIFT ${modalt}, up, workspace, e+1"
      "SHIFT ${modalt}, down, workspace, e-1"
      "SHIFT ${modalt}, right, workspace, r+1"
      "SHIFT ${modalt}, left, workspace, r-1"
      "${modalt}, mouse_down, workspace, e+1"
      "${modalt}, mouse_up, workspace, e-1"
      # Media keys
      ", XF86AudioStop, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioLowerVolume,exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioRaiseVolume,exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      "${modalt}, TAB, exec, hyprctl dispatch overview:toggle"
    ]
    ++ (
      # workspaces - bind $mod + [shift +] {1..9} to [move to] workspace {1..9}
      builtins.concatLists (builtins.genList
        (i: let ws = i + 1; in ["${mod}, ${toString ws}, movetoworkspace, ${toString ws}"])
        9)
    );
}
