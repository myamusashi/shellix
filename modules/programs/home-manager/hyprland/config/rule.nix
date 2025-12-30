let
  mkWindowRule = name: matches: effects:
    {inherit name;} // matches // effects;

  mkFloatCenterSize = name: matches: size:
    mkWindowRule name matches {
      float = true;
      center = true;
      inherit size;
    };

  mkFloat = name: matches:
    mkWindowRule name matches {float = true;};

  mkLayerRule = name: namespace: effects:
    {
      inherit name;
      "match:namespace" = namespace;
    }
    // effects;
in {
  windowrule = [
    # Common dialogs and popups
    (mkFloat "float_pavucontrol" {"match:class" = "^(pavucontrol)$";})
    (mkFloat "float_media_viewer" {"match:title" = "^(Media viewer)$";})
    (mkFloat "float_picture_in_picture" {"match:title" = "^(Picture-in-Picture)$";})
    (mkFloat "float_clipse" {"match:class" = "^(clipse)";})

    # Generic dialog types
    (mkFloat "float_file_progress" {"match:class" = "^(file_progress)$";})
    (mkFloat "float_confirm" {"match:class" = "^(confirm)$";})
    (mkFloat "float_dialog" {"match:class" = "^(dialog)$";})
    (mkFloat "float_download" {"match:class" = "^(download)$";})
    (mkFloat "float_notification" {"match:class" = "^(notification)$";})
    (mkFloat "float_error" {"match:class" = "^(error)$";})
    (mkFloat "float_confirmreset" {"match:class" = "^(confirmreset)$";})

    # Specific application dialogs
    (mkFloat "float_open_file" {"match:title" = "^(Open File)$";})
    (mkFloat "float_branchdialog" {"match:title" = "^(branchdialog)$";})
    (mkFloat "float_akun_google_title" {"match:title" = "^*.Akun Google.*";})
    (mkFloat "float_confirm_replace_files" {"match:title" = "^(Confirm to replace files)";})
    (mkFloat "float_file_operation_progress" {"match:title" = "^(File Operation Progress)";})
    (mkFloat "float_image_properties" {"match:title" = "^(Image Properties)$";})

    # Network and bluetooth
    (mkFloat "float_iwgtk_class" {"match:class" = "^(org.twosheds.iwgtk)$";})
    (mkFloat "float_iwgtk_title" {"match:title" = "^(iwgtk)$";})
    (mkFloat "float_blueman_manager" {"match:class" = "^(blueman-manager)$";})
    (mkFloat "float_bluetooth_devices" {"match:title" = "^(Bluetooth Devices)$";})

    # Application specific
    (mkFloat "float_rofi" {"match:class" = "^(Rofi)$";})
    (mkFloat "float_volume_control" {"match:title" = "^(Volume Control)$";})
    (mkFloat "float_friends_list" {"match:title" = "^(Friends List)";})
    (mkFloat "float_whatsapp_kdeconnect" {"match:title" = "^(WhatsApp — KDE Connect Daemon)";})
    (mkFloat "float_select_what_to_share" {"match:title" = "^(Select what to share)";})

    # Nemo file manager
    (mkWindowRule "float_nemo_properties" {
      "match:class" = "^(nemo)";
      "match:title" = ".*Properties";
    } {float = true;})

    # Bitwarden
    (mkFloat "float_bitwarden" {"match:title" = ".*Bitwarden.*";})

    # Portal dialogs
    (mkFloat "float_xdg_portal_gtk_open_folder" {
      "match:class" = "^(xdg-desktop-portal-gtk)";
      "match:title" = "^(Open Folder)";
    })
    (mkFloat "float_xdg_portal_kde" {
      "match:class" = "^(org.freedesktop.impl.portal.desktop.kde)";
    })

    # KDE Connect
    (mkFloat "float_kdeconnect_receiving_files" {
      "match:class" = "^(org.kde.kdeconnect.daemon)";
      "match:title" = "^(Receiving files)";
    })

    # Quickshell windows
    (mkFloat "float_quickshell_auth" {
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Authentication Required)";
    })
    (mkFloat "float_quickshell_recording" {
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Recording Widgets)";
    })

    # Zen browser
    (mkFloat "float_zen_google_login" {
      "match:class" = "^(zen)";
      "match:title" = "^(Login - Akun Google - Zen Browser)";
    })

    # Yazi file manager
    (mkFloat "float_yaziws" {"match:initial_title" = "^(yaziWS)";})

    (mkWindowRule "move_iwgtk" {"match:title" = "^(iwgtk)$";} {move = "40 44%";})
    (mkWindowRule "move_bluetooth_devices" {"match:title" = "^(Bluetooth Devices)$";} {move = "40 58%";})
    (mkWindowRule "move_quickshell_recording" {
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Recording Widgets)";
    } {move = "100%-w-20 100%-w-20";})

    (mkFloatCenterSize "yaziws" {"match:initial_title" = "^(yaziWS)";} "919 437")
    (mkFloatCenterSize "zen_google_login" {
      "match:class" = "^(zen)";
      "match:title" = "^(Login - Akun Google — Zen Browser)";
    } "900 710")
    (mkFloatCenterSize "xdg_portal_kde" {
      "match:class" = "^(org.freedesktop.impl.portal.desktop.kde)";
    } "500 500")
    (mkFloatCenterSize "select_what_to_share" {
      "match:title" = "^(Select what to share)";
    } "943 800")
    (mkFloatCenterSize "xdg_portal_gtk_open_folder" {
      "match:class" = "^(xdg-desktop-portal-gtk)";
      "match:title" = "^(Open Folder)";
    } "885 443")
    (mkFloatCenterSize "quickshell_wallpaper" {
      "match:float" = 1;
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Select a wallpaper)";
    } "1000 600")
    (mkFloatCenterSize "whatsapp_kdeconnect" {
      "match:title" = "^(WhatsApp — KDE Connect Daemon)";
    } "400 300")
    (mkFloatCenterSize "friends_list" {"match:title" = "^(Friends List)";} "300 650")
    (mkFloatCenterSize "clipse" {"match:class" = "^(clipse)";} "622 652")
    (mkFloatCenterSize "bitwarden" {"match:title" = ".*Bitwarden.*";} "380 630")
    (mkFloatCenterSize "netbeans" {"match:title" = "^(Starting Apache NetBeans IDE)$";} "480 300")
    (mkFloatCenterSize "vesktop" {"match:title" = "^(vesktop)$";} "300 350")
    (mkFloatCenterSize "akun_google" {"match:title" = "^*.Akun Google.*";} "954 641")
    (mkFloatCenterSize "hyprpanel_settings" {"match:title" = "^(hyprpanel-settings)$";} "800 600")
    (mkFloatCenterSize "hyprpanel_theme" {"match:title" = "^(Import Hyprpanel Theme)$";} "800 600")
    (mkFloatCenterSize "hyprland_polkit" {"match:title" = "^(Hyprland Polkit Agent)$";} "800 600")
    (mkFloatCenterSize "download" {"match:class" = "^(download)$";} "800 600")
    (mkFloatCenterSize "volume_control" {"match:title" = "^(Volume Control)$";} "800 600")
    (mkFloatCenterSize "image_properties" {"match:title" = "^(Image Properties)$";} "493 254")
    (mkFloatCenterSize "iwgtk" {"match:title" = "^(iwgtk)$";} "505 600")
    (mkFloatCenterSize "save_file" {"match:title" = "^(Enter name of file to save to…)$";} "885 463")
    (mkFloatCenterSize "bluetooth_devices" {"match:title" = "^(Bluetooth Devices)$";} "652 310")
    (mkFloatCenterSize "kdeconnect_receiving_files" {
      "match:class" = "^(org.kde.kdeconnect.daemon)";
      "match:title" = "^(Receiving files)";
    } "370 300")
    (mkFloatCenterSize "quickshell_auth" {
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Authentication Required)";
    } "530 520")
    (mkFloatCenterSize "quickshell_recording" {
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Recording Widgets)";
    } "300 230")
    (mkFloatCenterSize "eu_properties" {
      "match:class" = "^(eu.)";
      "match:title" = "^(Properties)";
    } "360 363")

    (mkWindowRule "center_steam" {
      "match:float" = 1;
      "match:title" = "^(Steam|Sign in to Steam)";
    } {center = true;})

    # Rofi variants
    (mkWindowRule "center_rofi_1" {"match:title" = "^(rofi - )$";} {center = true;})
    (mkWindowRule "center_rofi_2" {"match:title" = "^(rofi -  myamusashi@nixos)$";} {center = true;})
    (mkWindowRule "center_rofi_apps" {"match:title" = "^(rofi - APPS)$";} {center = true;})

    (mkWindowRule "stayfocused_clipse" {"match:class" = "^(clipse)";} {stay_focused = true;})
    (mkWindowRule "stayfocused_quickshell_auth" {
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Authentication Required)";
    } {stay_focused = true;})
    (mkWindowRule "stayfocused_yaziws" {"match:initial_title" = "^(yaziWS)";} {stay_focused = true;})

    (mkWindowRule "idleinhibit_mpv" {"match:class" = "^(mpv)$";} {idle_inhibit = "focus";})
    (mkWindowRule "idleinhibit_firefox" {"match:class" = "^(firefox)$";} {idle_inhibit = "fullscreen";})

    (mkWindowRule "opacity_spotify" {"match:title" = "^(Spotify)$";} {opacity = "0.90";})
    (mkWindowRule "opacity_zen" {"match:class" = "^(zen|zen-twilight|zen-beta)$";} {opacity = "1 override";})
    (mkWindowRule "opacity_vesktop" {"match:class" = "^(vesktop|discord)$";} {opacity = "1 override";})
    (mkWindowRule "opacity_nemo" {"match:class" = "^(nemo)$";} {opacity = "0.95";})

    (mkWindowRule "bordersize_xdg_portal_gtk" {
      "match:initial_class" = "^(Xdg-desktop-portal-gtk)$";
    } {border_size = 0;})
    (mkWindowRule "bordersize_xdg_portal_kde" {
      "match:initial_class" = "^(Xdg-desktop-portal-kde)$";
    } {border_size = 0;})

    (mkWindowRule "rounding_quickshell_auth" {
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Authentication Required)";
    } {rounding = 26;})
    (mkWindowRule "rounding_quickshell_recording" {
      "match:class" = "^(org.quickshell)";
      "match:title" = "^(Recording Widgets)";
    } {rounding = 26;})

    # Suppress maximize events for all apps
    (mkWindowRule "suppress-maximize-events" {
      "match:class" = ".*";
    } {suppress_event = "maximize";})

    # Fix XWayland dragging issues
    (mkWindowRule "fix-xwayland-drags" {
      "match:class" = "^$";
      "match:title" = "^$";
      "match:xwayland" = true;
      "match:float" = true;
      "match:fullscreen" = false;
      "match:pin" = false;
    } {no_focus = true;})
  ];

  layerrule = [
    (mkLayerRule "rofi_blur" "rofi" {blur = true;})
    (mkLayerRule "launcher_blur" "launcher" {blur = true;})
    (mkLayerRule "quickshell_blur" "quickshell" {blur = true;})
    (mkLayerRule "shell_dashboard_blur" "shell:dashboard" {blur = true;})
    (mkLayerRule "shell_bigclock_blur" "shell:bigclock" {blur = true;})
    (mkLayerRule "shell_app_blur" "shell:app" {blur = true;})
    (mkLayerRule "shell_bar_blur" "shell:bar" {blur = true;})
    (mkLayerRule "shell_capture_blur" "shell:capture" {blur = true;})
    (mkLayerRule "shell_session_blur" "shell:session" {blur = true;})

    # Popup animations (30%)
    (mkLayerRule "shell_bigclock_animation" "shell:bigclock" {animation = "popup 30%";})

    # Popup animations (90%)
    (mkLayerRule "shell_app_animation" "shell:app" {animation = "popup 90%";})
    (mkLayerRule "shell_capture_animation" "shell:capture" {animation = "popup 90%";})
    (mkLayerRule "shell_topExclusionZone_animation" "shell:topExclusionZone" {animation = "popup 90%";})
    (mkLayerRule "shell_bottomExclusionZone_animation" "shell:bottomExclusionZone" {animation = "popup 90%";})
    (mkLayerRule "shell_rightExclusionZone_animation" "shell:rightExclusionZone" {animation = "popup 90%";})
    (mkLayerRule "shell_leftExclusionZone_animation" "shell:leftExclusionZone" {animation = "popup 90%";})
    (mkLayerRule "quickshell_animation" "quickshell" {animation = "popup 90%";})

    # Popup animation (95%)
    (mkLayerRule "selection_animation" "selection" {animation = "popup 95%";})

    # Slide animations
    (mkLayerRule "shell_bar_animation" "shell:bar" {animation = "slide";})
    (mkLayerRule "shell_dashboard_animation" "shell:dashboard" {animation = "slide";})
    (mkLayerRule "shell_session_animation" "shell:session" {animation = "slide";})
    (mkLayerRule "shell_overview_animation" "shell:overview" {animation = "slide";})
  ];
}
