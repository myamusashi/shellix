{
  inputs,
  pkgs,
  ...
}: {
  term = "foot";
  screencapture = "qs -c lock ipc call screencapture toggle";
  gamemode = "/home/myamusashi/.dots/modules/programs/home-manager/hyprland/config/scripts/gamemode.sh";
  files = "footclient --title=yaziFM yazi";
  browser = "zen";
  vm = "vmware";
  launcher = "qs -c lock ipc call launcher toggle";
  powermenu = "qs -c lock ipc call session toggle";
  bar = "qs -c lock ipc call layerShell toggle";
  colorpick = "/home/myamusashi/.dots/modules/programs/home-manager/hyprland/config/scripts/picker.sh";
  dashboard = "${inputs.caelestia-cli.packages.${pkgs.system}.default}/bin/caelestia shell drawers toggle dashboard";
  lockscreen = "qs -c lock ipc call lock lock";
  emoji = "${pkgs.rofimoji}/bin/rofimoji --selector wofi";
  spotify = "spotify";
  discord = "vesktop";
  clipmanager = "kitty --class clipse -e clipse";
  modalt = "ALT";
  mod = "SUPER";
}
