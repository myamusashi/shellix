{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.matugen.nixosModules.default
  ];

  programs.matugen = {
    enable = true;
    variant = "dark";
    jsonFormat = "hex";
    palette = "scheme-content";

    templates = {
      kitty = {
        input_path = "./templates/kitty.conf";
        output_path = "~/.config/kitty/colors.conf";
      };
      gtk3 = {
        input_path = "./templates/gtk.css";
        output_path = "~/.config/gtk-3.0/gtk.css";
      };
      gtk4 = {
        input_path = "./templates/gtk.css";
        output_path = "~/.config/gtk-4.0/gtk.css";
      };
      yazi = {
        input_path = "./templates/yazi.toml";
        output_path = "~/.config/yazi/theme.toml";
      };
      wlogout = {
        input_path = "./templates/wlogout.css";
        output_path = "~/.config/wlogout/style.css";
      };
      rofi = {
        input_path = "./templates/rofi.rasi";
        output_path = "~/.config/rofi/colors.rasi";
      };
    };
  };
}
