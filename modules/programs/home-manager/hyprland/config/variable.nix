{config, ...}: let
  shell = "qs -c lock ipc call";
in {
  term = "foot";
  screencapture = "${shell} screencapture toggle";
  gamemode = "${config.home.homeDirectory}/.dots/modules/programs/home-manager/hyprland/config/scripts/gamemode.sh";
  files = "footclient --title=yaziFM yazi";
  browser = "zen";
  vm = "vmware";
  launcher = "${shell} launcher toggle";
  powermenu = "${shell} session toggle";
  bar = "${shell} layerShell toggle";
  colorpick = "${config.home.homeDirectory}/.dots/modules/programs/home-manager/hyprland/config/scripts/picker.sh";
  dashboard = "${shell} dashboard toggle";
  lockscreen = "${shell} lock lock";
  spotify = "spotify";
  discord = "vesktop";
  clipmanager = "kitty --class clipse -e clipse";
  modalt = "ALT";
  mod = "SUPER";
}
