{
  windowrule = [
    # Float rules
    {
      name = "float_pavucontrol";
      "match:class" = "^(pavucontrol)$";
      float = true;
    }
    {
      name = "float_media_viewer";
      "match:title" = "^(Media viewer)$";
      float = true;
    }
    {
      name = "float_volume_control";
      "match:title" = "^(Volume Control)$";
      float = true;
    }
    {
      name = "float_picture_in_picture";
      "match:title" = "^(Picture-in-Picture)$";
      float = true;
    }
    {
      name = "float_clipse";
      "match:class" = "^(clipse)";
      float = true;
    }
    {
      name = "float_file_progress";
      "match:class" = "^(file_progress)$";
      float = true;
    }
    {
      name = "float_confirm";
      "match:class" = "^(confirm)$";
      float = true;
    }
    {
      name = "float_dialog";
      "match:class" = "^(dialog)$";
      float = true;
    }
    {
      name = "float_download";
      "match:class" = "^(download)$";
      float = true;
    }
    {
      name = "float_notification";
      "match:class" = "^(notification)$";
      float = true;
    }
    {
      name = "float_error";
      "match:class" = "^(error)$";
      float = true;
    }
    {
      name = "float_confirmreset";
      "match:class" = "^(confirmreset)$";
      float = true;
    }
    {
      name = "float_open_file";
      "match:title" = "^(Open File)$";
      float = true;
    }
    {
      name = "float_branchdialog";
      "match:title" = "^(branchdialog)$";
      float = true;
    }
    {
      name = "float_akun_google_title";
      "match:title" = "^*.Akun Google.*";
      float = true;
    }
    {
      name = "float_confirm_replace_files";
      "match:title" = "^(Confirm to replace files)";
      float = true;
    }
    {
      name = "float_file_operation_progress";
      "match:title" = "^(File Operation Progress)";
      float = true;
    }
    {
      name = "float_iwgtk_class";
      "match:class" = "^(org.twosheds.iwgtk)$";
      float = true;
    }
    {
      name = "float_iwgtk_title";
      "match:title" = "^(iwgtk)$";
      float = true;
    }
    {
      name = "float_blueman_manager";
      "match:class" = "^(blueman-manager)$";
      float = true;
    }
    {
      name = "float_bluetooth_devices";
      "match:title" = "^(Bluetooth Devices)$";
      float = true;
    }
    {
      name = "float_rofi";
      "match:class" = "^(Rofi)$";
      float = true;
    }
    {
      name = "float_image_properties";
      "match:title" = "^(Image Properties)$";
      float = true;
    }
    {
      name = "float_nemo_properties";
      "match:class" = "^(nemo)";
      "match:title" = ".*Properties";
      float = true;
    }
    {
      name = "float_bitwarden";
      "match:title" = ".*Bitwarden.*";
      float = true;
    }
    {
      name = "float_xdg_portal_gtk_open_folder";
      "match:class" = "^(xdg-desktop-portal-gtk)";
      "match:title" = "^(Open Folder)";
      float = true;
    }
    {
      name = "float_friends_list";
      "match:title" = "^(Friends List)";
      float = true;
    }
    {
      name = "float_whatsapp_kdeconnect";
      "match:title" = "^(WhatsApp — KDE Connect Daemon)";
      float = true;
    }
    {
      name = "float_yaziws";
      "match:initial_title" = "^(yaziWS)";
      float = true;
    }
    {
      name = "float_xdg_portal_kde";
      "match:class" = "^(org.freedesktop.impl.portal.desktop.kde)";
      float = true;
    }
    {
      name = "float_select_what_to_share";
      "match:title" = "^(Select what to share)";
      float = true;
    }
    {
      name = "float_kdeconnect_receiving_files";
      "match:class" = "^(org.kde.kdeconnect.daemon)";
      "match:title" = "^(Receiving files)";
      float = true;
    }
    {
      name = "float_zen_google_login";
      "match:class" = "^(zen)";
      "match:title" = "^(Login - Akun Google - Zen Browser)";
      float = true;
    }

    # Move position rules
    {
      name = "move_iwgtk";
      "match:title" = "^(iwgtk)$";
      move = "40 44%";
    }
    {
      name = "move_bluetooth_devices";
      "match:title" = "^(Bluetooth Devices)$";
      move = "40 58%";
    }

    # Center rules
    {
      name = "center_yaziws";
      "match:initial_title" = "^(yaziWS)";
      center = true;
    }
    {
      name = "center_zen_google_login";
      "match:class" = "^(zen)";
      "match:title" = "^(Login - Akun Google — Zen Browser)";
      center = true;
    }
    {
      name = "center_xdg_portal_kde";
      "match:class" = "^(org.freedesktop.impl.portal.desktop.kde)";
      center = true;
    }
    {
      name = "center_kdeconnect_receiving_files";
      "match:class" = "^(org.kde.kdeconnect.daemon)";
      "match:title" = "^(Receiving files)";
      center = true;
    }
    {
      name = "center_select_what_to_share";
      "match:title" = "^(Select what to share)";
      center = true;
    }
    {
      name = "center_whatsapp_kdeconnect";
      "match:title" = "^(WhatsApp — KDE Connect Daemon)";
      center = true;
    }
    {
      name = "center_xdg_portal_gtk_open_folder";
      "match:class" = "^(xdg-desktop-portal-gtk)";
      "match:title" = "^(Open Folder)";
      center = true;
    }
    {
      name = "center_quickshell_wallpaper";
      "match:float" = 1;
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Select a wallpaper)";
      center = true;
    }
    {
      name = "center_steam";
      "match:float" = 1;
      "match:title" = "^(Steam|Sign in to Steam)";
      center = true;
    }
    {
      name = "center_volume_control";
      "match:title" = "^(Volume Control)$";
      center = true;
    }
    {
      name = "center_friends_list";
      "match:title" = "^(Friends List)";
      center = true;
    }
    {
      name = "center_netbeans";
      "match:title" = "^(Starting Apache NetBeans IDE)$";
      center = true;
    }
    {
      name = "center_bitwarden";
      "match:title" = ".*Bitwarden.*";
      center = true;
    }
    {
      name = "center_hyprpanel_theme";
      "match:title" = "^(Import Hyprpanel Theme)$";
      center = true;
    }
    {
      name = "center_hyprpanel_settings";
      "match:title" = "^(hyprpanel-settings)$";
      center = true;
    }
    {
      name = "center_hyprland_polkit";
      "match:title" = "^(Hyprland Polkit Agent)$";
      center = true;
    }
    {
      name = "center_rofi_1";
      "match:title" = "^(rofi - )$";
      center = true;
    }
    {
      name = "center_rofi_2";
      "match:title" = "^(rofi -  myamusashi@nixos)$";
      center = true;
    }
    {
      name = "center_rofi_apps";
      "match:title" = "^(rofi - APPS)$";
      center = true;
    }
    {
      name = "center_image_properties";
      "match:title" = "^(Image Properties)$";
      center = true;
    }
    {
      name = "center_save_file";
      "match:title" = "^(Enter name of file to save to…)$";
      center = true;
    }
    {
      name = "center_vesktop";
      "match:title" = "^(vesktop)$";
      center = true;
    }
    {
      name = "center_eu_properties";
      "match:class" = "^(eu.)";
      "match:title" = "^(Properties|Select icon)";
      center = true;
    }

    # Size rules
    {
      name = "size_yaziws";
      "match:initial_title" = "^(yaziWS)";
      size = "919 437";
    }
    {
      name = "size_zen_google_login";
      "match:class" = "^(zen)";
      "match:title" = "^(Login - Akun Google - Zen Browser)";
      size = "900 710";
    }
    {
      name = "size_xdg_portal_kde";
      "match:class" = "^(org.freedesktop.impl.portal.desktop.kde)";
      size = "500 500";
    }
    {
      name = "size_select_what_to_share";
      "match:title" = "^(Select what to share)";
      size = "943 800";
    }
    {
      name = "size_xdg_portal_kde_open_folder";
      "match:class" = "^(xdg-desktop-portal-kde)";
      "match:title" = "^(Open Folder)";
      size = "885 443";
    }
    {
      name = "size_quickshell_wallpaper";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Select a wallpaper)";
      size = "1000 600";
    }
    {
      name = "size_whatsapp_kdeconnect";
      "match:title" = "^(WhatsApp — KDE Connect Daemon)";
      size = "400 300";
    }
    {
      name = "size_eu_properties";
      "match:class" = "^(eu.)";
      "match:title" = "^(Properties)";
      size = "360 363";
    }
    {
      name = "size_friends_list";
      "match:title" = "^(Friends List)";
      size = "300 650";
    }
    {
      name = "size_clipse";
      "match:class" = "^(clipse)";
      size = "622 652";
    }
    {
      name = "size_bitwarden";
      "match:title" = ".*Bitwarden.*";
      size = "380 630";
    }
    {
      name = "size_netbeans";
      "match:title" = "^(Starting Apache NetBeans IDE)$";
      size = "480 300";
    }
    {
      name = "size_vesktop";
      "match:title" = "^(vesktop)$";
      size = "300 350";
    }
    {
      name = "size_akun_google";
      "match:title" = "^*.Akun Google.*";
      size = "954 641";
    }
    {
      name = "size_hyprpanel_settings";
      "match:title" = "^(hyprpanel-settings)$";
      size = "800 600";
    }
    {
      name = "size_hyprpanel_theme";
      "match:title" = "^(Import Hyprpanel Theme)$";
      size = "800 600";
    }
    {
      name = "size_hyprland_polkit";
      "match:title" = "^(Hyprland Polkit Agent)$";
      size = "800 600";
    }
    {
      name = "size_download";
      "match:class" = "^(download)$";
      size = "800 600";
    }
    {
      name = "size_volume_control";
      "match:title" = "^(Volume Control)$";
      size = "800 600";
    }
    {
      name = "size_image_properties";
      "match:title" = "^(Image Properties)$";
      size = "493 254";
    }
    {
      name = "size_iwgtk";
      "match:title" = "^(iwgtk)$";
      size = "505 600";
    }
    {
      name = "size_save_file";
      "match:title" = "^(Enter name of file to save to…)$";
      size = "885 463";
    }
    {
      name = "size_bluetooth_devices";
      "match:title" = "^(Bluetooth Devices)$";
      size = "652 310";
    }
    {
      name = "size_kdeconnect_receiving_files";
      "match:class" = "^(org.kde.kdeconnect.daemon)";
      "match:title" = "^(Receiving files)";
      size = "370 300";
    }

    # Misc rules - stayfocused
    {
      name = "stayfocused_clipse";
      "match:class" = "^(clipse)";
      stay_focused = true;
    }
    {
      name = "stayfocused_quickshell_auth";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Authentication Required)";
      stay_focused = true;
    }
    {
      name = "stayfocused_yaziws";
      "match:initial_title" = "^(yaziWS)";
      stay_focused = true;
    }

    # Idle inhibit rules
    {
      name = "idleinhibit_mpv";
      "match:class" = "^(mpv)$";
      idle_inhibit = "focus";
    }
    {
      name = "idleinhibit_firefox";
      "match:class" = "^(firefox)$";
      idle_inhibit = "fullscreen";
    }

    # Opacity rules
    {
      name = "opacity_spotify";
      "match:title" = "^(Spotify)$";
      opacity = "0.90";
    }
    {
      name = "opacity_zen";
      "match:class" = "^(zen|zen-twilight|zen-beta)$";
      opacity = "1 override";
    }
    {
      name = "opacity_vesktop";
      "match:class" = "^(vesktop|discord)$";
      opacity = "1 override";
    }
    {
      name = "opacity_nemo";
      "match:class" = "^(nemo)$";
      opacity = "0.95";
    }

    # No blur rule (commented out)
    # {
    #   name = "noblur_xwayland";
    #   "match:xwayland" = 1;
    #   noblur = true;
    # }

    # Border size rules
    {
      name = "bordersize_xdg_portal_gtk";
      "match:initial_class" = "^(Xdg-desktop-portal-gtk)$";
      border_size = 0;
    }
    {
      name = "bordersize_xdg_portal_kde";
      "match:initial_class" = "^(Xdg-desktop-portal-kde)$";
      border_size = 0;
    }

    # Quickshell window rules
    {
      name = "float_quickshell_auth";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Authentication Required)";
      float = true;
    }
    {
      name = "float_quickshell_recording";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Recording Widgets)";
      float = true;
    }

    # Bottom-right position for Recording Widgets
    {
      name = "move_quickshell_recording";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Recording Widgets)";
      move = "100%-w-20 100%-w-20";
    }

    {
      name = "center_quickshell_auth";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Authentication Required)";
      center = true;
    }

    {
      name = "size_quickshell_auth";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Authentication Required)";
      size = "530 520";
    }
    {
      name = "size_quickshell_recording";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Recording Widgets)";
      size = "300 230";
    }

    {
      name = "rounding_quickshell_auth";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Authentication Required)";
      rounding = 26;
    }
    {
      name = "rounding_quickshell_recording";
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Recording Widgets)";
      rounding = 26;
    }

    # Suppress maximize events for all apps
    {
      name = "suppress-maximize-events";
      "match:class" = ".*";
      suppress_event = "maximize";
    }

    # Fix XWayland dragging issues
    {
      name = "fix-xwayland-drags";
      "match:class" = "^$";
      "match:title" = "^$";
      "match:xwayland" = true;
      "match:float" = true;
      "match:fullscreen" = false;
      "match:pin" = false;
      no_focus = true;
    }
  ];

  layerrule = [
    # Layer blur
    {
      name = "rofi_blur";
      "match:namespace" = "rofi";
      blur = true;
    }
    {
      name = "launcher_blur";
      "match:namespace" = "launcher";
      blur = true;
    }
    {
      name = "quickshell_blur";
      "match:namespace" = "quickshell";
      blur = true;
    }
    {
      name = "shell_dashboard_blur";
      "match:namespace" = "shell:dashboard";
      blur = true;
    }
    {
      name = "shell_bigclock_blur";
      "match:namespace" = "shell:bigclock";
      blur = true;
    }
    {
      name = "shell_app_blur";
      "match:namespace" = "shell:app";
      blur = true;
    }
    {
      name = "shell_bar_blur";
      "match:namespace" = "shell:bar";
      blur = true;
    }
    {
      name = "shell_capture_blur";
      "match:namespace" = "shell:capture";
      blur = true;
    }
    {
      name = "shell_session_blur";
      "match:namespace" = "shell:session";
      blur = true;
    }

    # Layer animation
    {
      name = "shell_bigclock_animation";
      "match:namespace" = "shell:bigclock";
      animation = "popup 30%";
    }
    {
      name = "selection_animation";
      "match:namespace" = "selection";
      animation = "popup 95%";
    }
    {
      name = "shell_app_animation";
      "match:namespace" = "shell:app";
      animation = "popup 90%";
    }
    {
      name = "shell_capture_animation";
      "match:namespace" = "shell:capture";
      animation = "popup 90%";
    }
    {
      name = "shell_topExclusionZone_animation";
      "match:namespace" = "shell:topExclusionZone";
      animation = "popup 90%";
    }
    {
      name = "shell_bottomExclusionZone_animation";
      "match:namespace" = "shell:bottomExclusionZone";
      animation = "popup 90%";
    }
    {
      name = "shell_rightExclusionZone_animation";
      "match:namespace" = "shell:rightExclusionZone";
      animation = "popup 90%";
    }
    {
      name = "shell_leftExclusionZone_animation";
      "match:namespace" = "shell:leftExclusionZone";
      animation = "popup 90%";
    }
    {
      name = "quickshell_animation";
      "match:namespace" = "quickshell";
      animation = "popup 90%";
    }
    {
      name = "shell_bar_animation";
      "match:namespace" = "shell:bar";
      animation = "slide";
    }
    {
      name = "shell_dashboard_animation";
      "match:namespace" = "shell:dashboard";
      animation = "slide";
    }
    {
      name = "shell_session_animation";
      "match:namespace" = "shell:session";
      animation = "slide";
    }
    {
      name = "shell_overview_animation";
      "match:namespace" = "shell:overview";
      animation = "slide";
    }
  ];
}
