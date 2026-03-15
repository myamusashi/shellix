let
    mkWindowRule = name: matches: effects:
        {inherit name;} // matches // effects;

    mkLayerRule = name: namespace: effects:
        {
            inherit name;
            "match:namespace" = namespace;
        }
        // effects;

    mkFloat = name: matches:
        mkWindowRule name matches {float = true;};

    mkFloatCenterSize = name: matches: size:
        mkWindowRule name matches {
            float = true;
            center = true;
            inherit size;
        };

    matchClass = class: {"match:class" = class;};
    matchTitle = title: {"match:title" = title;};
    matchProps = class: title: matchClass class // matchTitle title;
    matchInitialTitle = title: {"match:initial_title" = title;};
    matchInitialClass = class: {"match:initial_class" = class;};

    floatCenterSized = name: matches: size:
        mkFloatCenterSize name matches size;
in {
    windowrule = [
        # ===== Common Dialogs =====
        (mkFloat "float_pavucontrol" (matchClass "^pavucontrol$"))
        (mkFloat "float_media_viewer" (matchTitle "^Media viewer$"))
        (mkFloat "float_picture_in_picture" (matchTitle "^Picture-in-Picture$"))
        (mkFloat "float_clipse" (matchClass "^clipse"))

        # ===== Generic dialog types =====
        (mkFloat "float_file_progress" (matchClass "^file_progress$"))
        (mkFloat "float_confirm" (matchClass "^confirm$"))
        (mkFloat "float_dialog" (matchClass "^dialog$"))
        (mkFloat "float_download" (matchClass "^download$"))
        (mkFloat "float_notification" (matchClass "^notification$"))
        (mkFloat "float_error" (matchClass "^error$"))
        (mkFloat "float_confirmreset" (matchClass "^confirmreset$"))

        # ===== Application-Specific Dialogs =====
        (mkFloat "float_open_file" (matchTitle "^Open File$"))
        (mkFloat "float_branchdialog" (matchTitle "^branchdialog$"))
        (mkFloat "float_confirm_replace_files" (matchTitle "^Confirm to replace files"))
        (mkFloat "float_file_operation_progress" (matchTitle "^File Operation Progress"))
        (mkFloat "float_image_properties" (matchTitle "^Image Properties$"))

        # ===== Network & Bluetooth =====
        (mkFloat "float_iwgtk_class" (matchClass "^org\\.twosheds\\.iwgtk$"))
        (mkFloat "float_iwgtk_title" (matchTitle "^iwgtk$"))
        (mkFloat "float_blueman_manager" (matchClass "^blueman-manager$"))
        (mkFloat "float_bluetooth_devices" (matchTitle "^Bluetooth Devices$"))

        # ===== Desktop Tools =====
        (mkFloat "float_rofi" (matchClass "^Rofi$"))
        (mkFloat "float_volume_control" (matchTitle "^Volume Control$"))
        (mkFloat "float_select_what_to_share" (matchTitle "^Select what to share"))

        # ===== File Managers =====
        (mkWindowRule "float_nemo_properties" (matchProps "^nemo" ".*Properties") {float = true;})
        (mkWindowRule "float_dolphin_move" (matchClass "^Move Files") {
            float = true;
            idle_inhibit = "focus";
            size = "660 360";
        })

        # ===== XDG Portals =====
        (mkFloat "float_xdg_portal_gtk" (matchProps "^xdg-desktop-portal-gtk" "^Open Folder"))
        (mkFloat "float_xdg_portal_kde" (matchClass "^org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde"))

        # ===== Quickshell Windows =====
        (mkFloat "float_quickshell_auth" (matchProps "^org\\.quickshell" "^Authentication Required"))
        (mkFloat "float_quickshell_recording" (matchProps "^org\\.quickshell" "^Recording Widgets"))

        # ===== Browser-Specific =====
        (mkFloat "float_zen_google_login" (matchProps "^zen" "^Login - Akun Google - Zen Browser"))
        (mkFloat "float_akun_google_title" (matchTitle "Akun Google"))

        # ===== Messaging & Social =====
        (mkFloat "float_friends_list" (matchTitle "^Friends List"))
        (mkFloat "float_whatsapp_kdeconnect" (matchTitle "^WhatsApp — KDE Connect Daemon"))
        (mkFloat "float_bitwarden" (matchTitle "Bitwarden"))

        # ===== KDE Connect =====
        (mkFloat "float_kdeconnect_receiving" (matchProps "^org\\.kde\\.kdeconnect\\.daemon" "^Receiving files"))

        # ===== Image Preview =====
        (mkFloat "float_yazi_image_preview" (matchClass "^ueberzugpp"))
        (mkWindowRule "resize_yazi_image_preview" (matchClass "^ueberzugpp") {size = "295 199";})

        # ===== Terminal File Managers =====
        (mkFloat "float_yaziws" (matchInitialTitle "^yaziWS"))

        # ===== Window Positioning =====
        (mkWindowRule "move_iwgtk" (matchTitle "^iwgtk$") {move = "40 44%";})
        (mkWindowRule "move_bluetooth_devices" (matchTitle "^Bluetooth Devices$") {move = "40 58%";})
        (mkWindowRule "move_quickshell_recording" (matchProps "^org\\.quickshell" "^Recording Widgets") {move = "100%-w-20 100%-w-20";})

        # ===== Quickshell settings =====
        (mkWindowRule "QsSettings" (matchProps "org.quickshell" "Settings") {
            float = "on";
            no_shadow = "on";
            rounding = "on";
            border_size = 0;
        })

        # ===== Float + Center + Size Rules =====
        (floatCenterSized "yaziws" (matchInitialTitle "^yaziWS") "919 437")
        (floatCenterSized "zen_google_login" (matchProps "^zen" "^Login - Akun Google — Zen Browser") "900 710")
        (floatCenterSized "xdg_portal_kde" (matchClass "^org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde") "500 500")
        (floatCenterSized "select_what_to_share" (matchTitle "^Select what to share") "943 800")
        (floatCenterSized "xdg_portal_gtk_open_folder" (matchProps "^xdg-desktop-portal-gtk" "^Open Folder") "885 443")
        (floatCenterSized "quickshell_wallpaper" ({"match:float" = 1;} // matchProps "^org\\.quickshell" "^Select a wallpaper") "1000 600")
        (floatCenterSized "whatsapp_kdeconnect" (matchTitle "^WhatsApp — KDE Connect Daemon") "400 300")
        (floatCenterSized "friends_list" (matchTitle "^Friends List") "300 650")
        (floatCenterSized "clipse" (matchClass "^clipse") "622 652")
        (floatCenterSized "bitwarden" (matchTitle "Bitwarden") "380 630")
        (floatCenterSized "netbeans" (matchTitle "^Starting Apache NetBeans IDE$") "480 300")
        (floatCenterSized "vesktop" (matchTitle "^vesktop$") "300 350")
        (floatCenterSized "akun_google" (matchTitle "Akun Google") "954 641")
        (floatCenterSized "hyprpanel_settings" (matchTitle "^hyprpanel-settings$") "800 600")
        (floatCenterSized "hyprpanel_theme" (matchTitle "^Import Hyprpanel Theme$") "800 600")
        (floatCenterSized "hyprland_polkit" (matchTitle "^Hyprland Polkit Agent$") "800 600")
        (floatCenterSized "download" (matchClass "^download$") "800 600")
        (floatCenterSized "volume_control" (matchTitle "^Volume Control$") "800 600")
        (floatCenterSized "image_properties" (matchTitle "^Image Properties$") "493 254")
        (floatCenterSized "iwgtk" (matchTitle "^iwgtk$") "505 600")
        (floatCenterSized "save_file" (matchTitle "^Enter name of file to save to…$") "885 463")
        (floatCenterSized "bluetooth_devices" (matchTitle "^Bluetooth Devices$") "652 310")
        (floatCenterSized "kdeconnect_receiving_files" (matchProps "^org\\.kde\\.kdeconnect\\.daemon" "^Receiving files") "370 300")
        (floatCenterSized "quickshell_auth" (matchProps "^org\\.quickshell" "^Authentication Required") "530 520")
        (floatCenterSized "quickshell_recording" (matchProps "^org\\.quickshell" "^Recording Widgets") "300 230")
        (floatCenterSized "eu_properties" (matchProps "^eu\\." "^Properties") "360 363")

        # ===== Center-Only Rules =====
        (mkWindowRule "center_steam" ({"match:float" = 1;} // matchTitle "^(Steam|Sign in to Steam)") {center = true;})
        (mkWindowRule "center_rofi_1" (matchTitle "^rofi - $") {center = true;})
        (mkWindowRule "center_rofi_2" (matchTitle "^rofi -  myamusashi@nixos$") {center = true;})
        (mkWindowRule "center_rofi_apps" (matchTitle "^rofi - APPS$") {center = true;})

        # ===== Focus Rules =====
        (mkWindowRule "stayfocused_clipse" (matchClass "^clipse") {stay_focused = true;})
        (mkWindowRule "stayfocused_quickshell_auth" (matchProps "^org\\.quickshell" "^Authentication Required") {stay_focused = true;})
        (mkWindowRule "stayfocused_yaziws" (matchInitialTitle "^yaziWS") {stay_focused = true;})

        # ===== Idle Inhibit =====
        (mkWindowRule "idleinhibit_mpv" (matchClass "^mpv$") {idle_inhibit = "focus";})
        (mkWindowRule "idleinhibit_firefox" (matchClass "^firefox$") {idle_inhibit = "fullscreen";})

        # ===== Opacity =====
        (mkWindowRule "opacity_spotify" (matchTitle "^Spotify$") {opacity = "0.90";})
        (mkWindowRule "opacity_zen" (matchClass "^zen(-twilight|-beta)?$") {opacity = "1 override";})
        (mkWindowRule "opacity_vesktop" (matchClass "^(vesktop|discord)$") {opacity = "1 override";})
        (mkWindowRule "opacity_nemo" (matchClass "^nemo$") {opacity = "0.95";})

        # ===== Border Size =====
        (mkWindowRule "bordersize_xdg_portal_gtk" (matchInitialClass "^Xdg-desktop-portal-gtk$") {border_size = 0;})
        (mkWindowRule "bordersize_xdg_portal_kde" (matchInitialClass "^Xdg-desktop-portal-kde$") {border_size = 0;})

        # ===== Rounding =====
        (mkWindowRule "rounding_quickshell_auth" (matchProps "^org\\.quickshell" "^Authentication Required") {rounding = 26;})
        (mkWindowRule "rounding_quickshell_recording" (matchProps "^org\\.quickshell" "^Recording Widgets") {rounding = 26;})

        # ===== Global Rules =====
        (mkWindowRule "suppress_maximize_all" {"match:class" = ".*";} {suppress_event = "maximize";})
        (mkWindowRule "fix_xwayland_drags" {
            "match:class" = "^$";
            "match:title" = "^$";
            "match:xwayland" = true;
            "match:float" = true;
            "match:fullscreen" = false;
            "match:pin" = false;
        } {no_focus = true;})
    ];

    layerrule = let
        popup30 = {animation = "popup 30%";};
        popup90 = {animation = "popup 90%";};
        popup95 = {animation = "popup 95%";};
    in [
        (mkLayerRule "rofi_blur" "rofi" {blur = true;})
        (mkLayerRule "launcher_blur" "launcher" {blur = true;})
        (mkLayerRule "quickshell_blur" "quickshell" {blur = true;})
        (mkLayerRule "shell_dashboard_blur" "shell:dashboard" {blur = true;})
        (mkLayerRule "shell_bigclock_blur" "shell:bigclock" {blur = true;})
        (mkLayerRule "shell_app_blur" "shell:app" {blur = true;})
        (mkLayerRule "shell_capture_blur" "shell:capture" {blur = true;})
        (mkLayerRule "shell_session_blur" "shell:session" {blur = true;})
        (mkLayerRule "shell_drawers_no_blur" "shell:drawers" {blur = true;})

        (mkLayerRule "shell_bigclock_animation" "shell:bigclock" popup30)

        (mkLayerRule "shell_drawers_animation" "shell:drawers" popup90)
        (mkLayerRule "shell_app_animation" "shell:app" popup90)
        (mkLayerRule "shell_capture_animation" "shell:capture" popup90)
        (mkLayerRule "shell_top_exclusion" "shell:topExclusionZone" popup90)
        (mkLayerRule "shell_bottom_exclusion" "shell:bottomExclusionZone" popup90)
        (mkLayerRule "shell_right_exclusion" "shell:rightExclusionZone" popup90)
        (mkLayerRule "shell_left_exclusion" "shell:leftExclusionZone" popup90)
        (mkLayerRule "quickshell_animation" "quickshell" popup90)

        (mkLayerRule "shell_dashboard_animation" "shell:dashboard" popup95)
        (mkLayerRule "selection_animation" "selection" popup95)
    ];
}
