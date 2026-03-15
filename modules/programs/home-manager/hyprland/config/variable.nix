{config, ...}: let
    shell = "hyprctl dispatch global quickshell";
    app2unit = "app2unit --";
in {
    "$term" = "${app2unit} kitty";
    "$screencapture" = "${shell}:screencaptureLauncher";
    "$wallpaper-switcher" = "${shell}:wallpaperSwitcher";
    "$setting-window" = "${shell}:settings";
    "$weather-panel" = "${shell}:weather";
    "$gamemode" = "${config.home.homeDirectory}/.dots/modules/programs/home-manager/hyprland/config/scripts/gamemode.sh";
    "$record-panel" = "${shell}:recordPanel";
    "$files" = "${app2unit} footclient --title=yaziFM yazi";
    "$browser" = "${app2unit} zen-twilight";
    "$vm" = "${app2unit} vmware";
    "$launcher" = "${shell}:appLauncher";
    "$powermenu" = "${shell}:session";
    "$bar" = "${shell}:layershell";
    "$colorpick" = "${config.home.homeDirectory}/.dots/modules/programs/home-manager/hyprland/config/scripts/picker.sh";
    "$dashboard" = "${shell}:dashboard";
    "$lockscreen" = "shell ipc call lock lock";
    "$spotify" = "${app2unit} spotify";
    "$discord" = "${app2unit} vesktop";
    "$clipmanager" = "kitty --class clipse -e clipse";
    "$modalt" = "ALT";
    "$mod" = "SUPER";
}
