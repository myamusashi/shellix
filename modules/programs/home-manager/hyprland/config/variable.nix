{config, ...}: let
  shell = "hyprctl dispatch global quickshell";
in {
  term = "kitty";
  screencapture = "${shell}:screencapture";
  wallpaper-switcher = "${shell}:wallpaperSelector";
  gamemode = "${config.home.homeDirectory}/.dots/modules/programs/home-manager/hyprland/config/scripts/gamemode.sh";
  files = "footclient --title=yaziFM yazi";
  browser = "zen";
  vm = "vmware";
  launcher = "${shell}:appLauncher";
  powermenu = "${shell}:session";
  bar = "${shell}:bar";
  colorpick = "${config.home.homeDirectory}/.dots/modules/programs/home-manager/hyprland/config/scripts/picker.sh";
  dashboard = "${shell}:dashboard";
  lockscreen = "qs -c lock ipc call lock lock";
  spotify = "spotify";
  discord = "vesktop";
  clipmanager = "kitty --class clipse -e clipse";
  modalt = "ALT";
  mod = "SUPER";
}
