{
  inputs,
  pkgs,
  ...
}: {
  term = "foot";
  screencapture = "/home/myamusashi/.dots/modules/programs/home-manager/hyprland/config/scripts/screen-capture.sh";
  gamemode = "/home/myamusashi/.dots/modules/programs/home-manager/hyprland/config/scripts/gamemode.sh";
  files = "footclient --title=yaziFM yazi";
  browser = "zen";
  vm = "vmware";
  launcher = "${inputs.caelestia-cli.packages.${pkgs.system}.default}/bin/caelestia shell drawers toggle launcher";
  powermenu = "${inputs.caelestia-cli.packages.${pkgs.system}.default}/bin/caelestia shell drawers toggle session";
  bar = "${inputs.caelestia-cli.packages.${pkgs.system}.default}/bin/caelestia shell drawers toggle bar";
  colorpick = "/home/myamusashi/.dots/modules/programs/home-manager/hyprland/config/scripts/picker.sh";
  dashboard = "${inputs.caelestia-cli.packages.${pkgs.system}.default}/bin/caelestia shell drawers toggle dashboard";
  lockscreen = "${inputs.caelestia-cli.packages.${pkgs.system}.default}/bin/caelestia shell lock lock";
  emoji = "${pkgs.rofimoji}/bin/rofimoji --selector wofi";
  spotify = "spotify";
  discord = "vesktop";
  clipmanager = "kitty --class clipse -e clipse";
  modalt = "ALT";
  mod = "SUPER";
}
