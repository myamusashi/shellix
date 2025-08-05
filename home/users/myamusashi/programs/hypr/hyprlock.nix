{pkgs, ...}: let
  matugenrgb = import ./colors/matugen_rgba.nix;
  matugenhex = import ./colors/matugen.nix;

  fontFamily = "ProggyClean Nerd Font";
in {
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;
    settings = {
      general = {
        hide_cursor = false;
        ignore_empty_input = true;
      };
    };
  };
  programs.hyprlock.extraConfig = ''
     background {
       monitor =
       color = rgba(255,255,255,0)
    path = $HOME/Pictures/wallpapers/yuzuha.jpg
    blur_passes = 2
     }

     # TIME
     label {
       monitor = eDP-1
       text = cmd[update:30000] echo "$(date +'%R')"
       color = ${matugenrgb.on_primary}
       font_size = 70
       font_family = ${fontFamily}
       position = 0, 50
       halign = center
       valign = center
     }

     label {
       monitor = HDMI-A-2
       text = cmd[update:30000] echo "$(date +'%R')"
       color = ${matugenrgb.on_primary}
       font_size = 70
       font_family = ${fontFamily}
       position = 0, -10
       halign = center
       valign = center
     }

     # DATE
     label {
       monitor = eDP-1
       text = cmd[update:43200000] echo "$(date +'%A, %d %B %Y')"
       color = ${matugenrgb.on_primary_fixed}
       font_size = 25
       font_family = ${fontFamily}
       position = 0, -10
       halign = center
       valign = center
     }

     label {
       monitor = HDMI-A-2
       text = cmd[update:43200000] echo "$(date +'%A, %d %B %Y')"
       color = ${matugenrgb.on_primary_fixed}
       font_size = 25
       font_family = ${fontFamily}
       position = 0, -70
       halign = center
       valign = center

     }

     # USER AVATAR
     image {
       monitor = eDP-1
       path = $HOME/.face
       size = 80
       rounding = -1
       rotate = 0
       reload_time = -1
       border_size = 0
       position = 0, 220
       halign = center
       valign = center
     }

     image {
       monitor = HDMI-A-2
       path = $HOME/.face
       size = 80
       rounding = -1
       rotate = 0
       reload_time = -1
       border_size = 0
       position = 0, 200
       halign = center
       valign = center
     }

     # SHAPE
     shape {
       monitor = eDP-1
       size = 480, 480
       color = ${matugenrgb.on_secondary_container}
       rounding = 30
       rotate = 0
       xray = false
       position = 0, -25
       halign = center
       valign = center
     }

     shape {
       monitor = HDMI-A-2
       size = 550, 550
       color = ${matugenrgb.on_secondary_container}
       rounding = 30
       rotate = 0
       xray = false
       position = 0, -80
       halign = center
       valign = center
     }

     # NAME
     shape {
       monitor = eDP-1
       size = 300, 60
       color = ${matugenrgb.on_primary}
       rounding = -1
       border_size = 4
       border_color = ${matugenrgb.inverse_on_surface}
       xray = false
       rotate = 0
       position = 0, -100
       halign = center
       valign = center
     }

     label {
       monitor = eDP-1
       text =  $USER
       color = ${matugenrgb.primary}
       font_size = 25
       font_family = ${fontFamily}
       position = 0, -100
       halign = center
       valign = center
     }

     shape {
       monitor = HDMI-A-2
       size = 300, 60
       color = ${matugenrgb.primary}
       rounding = -1
       border_size = 4
       border_color = ${matugenrgb.inverse_on_surface}
       xray = false
       rotate = 0
       position = 0, -200
       halign = center
       valign = center
     }

     label {
       monitor = HDMI-A-2
       text =  $USER
       color = ${matugenrgb.on_primary}
       font_size = 25
       font_family = ${fontFamily}
       position = 0, -200
       halign = center
       valign = center
     }

     # INPUT PASSWORD FIELD
     input-field {
       monitor = eDP-1
       size = 300, 60
       outline_thickness = 4
       dots_size = 0.2
       dots_spacing = 0.2
       dots_center = true
       outer_color = ${matugenrgb.outline}
       inner_color = ${matugenrgb.surface}
       font_color = ${matugenrgb.secondary}
       fade_on_empty = false
       placeholder_text = <i><span foreground='##${matugenhex.surface_tint}'>󰌾 Aduh </span> <span foreground='##${matugenhex.secondary}'><b>gantengnya</b></span></i>
       hide_input = false
    fail_color = ${matugenrgb.error}
       fail_text = <i>Tolol, Coba lagi<b>($ATTEMPTS)</b></i>
       capslock_color = ${matugenrgb.on_primary}
       position = 0, -185
       halign = center
       valign = center
     }

     # INPUT PASSWORD FIELD
     input-field {
       monitor = HDMI-A-2
       size = 300, 60
       outline_thickness = 4
       dots_size = 0.2
       dots_spacing = 0.2
       dots_center = true
       outer_color = ${matugenrgb.outline}
       inner_color = ${matugenrgb.surface}
       font_color = ${matugenrgb.secondary}
       fade_on_empty = false
       placeholder_text = <i><span foreground='##${matugenhex.surface_tint}'>󰌾 Aduh </span> <span foreground='##${matugenhex.secondary}'><b>gantengnya</b></span></i>
       hide_input = false
       fail_color = ${matugenrgb.error}
    fail_text = <i>Tolol, Coba lagi<b>($ATTEMPTS)</b></i>
       capslock_color = ${matugenrgb.on_primary}
       position = 0, -285
       halign = center
       valign = center
     }
  '';
}
