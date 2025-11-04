{
  windowrulev2 = [
    # Float rules
    "float,class:^(pavucontrol)$"
    "float,title:^(Media viewer)$"
    "float,title:^(Volume Control)$"
    "float,title:^(Picture-in-Picture)$"
    "float,class:^(clipse)"
    "float,class:^(file_progress)$"
    "float,class:^(confirm)$"
    "float,class:^(dialog)$"
    "float,class:^(download)$"
    "float,class:^(notification)$"
    "float,class:^(error)$"
    "float,class:^(confirmreset)$"
    "float,title:^(Open File)$"
    "float,title:^(branchdialog)$"
    "float,title:^*.Akun Google.*"
    "float,title:^(Confirm to replace files)"
    "float,title:^(File Operation Progress)"
    "float,class:^(org.twosheds.iwgtk)$"
    "float,title:^(iwgtk)$"
    "float,class:^(blueman-manager)$"
    "float,title:^(Bluetooth Devices)$"
    "float,class:^(Rofi)$"
    "float,title:^(Image Properties)$"
    "float,class:^(nemo),title:.*Properties"
    "float,title:.*Bitwarden.*"
    "float,class:^(xdg-desktop-portal-gtk),title:^(Open Folder)"
    "float,title:^(Friends List)"
    "float,title:^(WhatsApp — KDE Connect Daemon)"
    "float,initialTitle:^(yaziWS)"
    "float,class:^(org.freedesktop.impl.portal.desktop.kde)"
    "float,title:^(Select what to share)"
    "float,class:^(org.kde.kdeconnect.daemon),title:^(Receiving files)"
	"float,class:^(zen),title:^(Login - Akun Google - Zen Browser)"

    # Move position rules
    "move 40 44%,title:^(iwgtk)$"
    "move 40 58%,title:^(Bluetooth Devices)$"

    # Center rules
    "center,initialTitle:^(yaziWS)"
	"center,class:^(zen),title:^(Login - Akun Google — Zen Browser)"
    "center,class:^(org.freedesktop.impl.portal.desktop.kde)"
    "center,class:^(org.kde.kdeconnect.daemon),title:^(Receiving files)"
    "center,title:^(Select what to share)"
    "center,title:^(WhatsApp — KDE Connect Daemon)"
    "center,class:^(xdg-desktop-portal-gtk),title:^(Open Folder)"
    "center,floating:1,class:^(org.quickshell),title:^(Select a wallpaper)"
    "center,floating:1,title:^(Steam|Sign in to Steam)"
    "center,title:^(Volume Control)$"
    "center,title:^(Friends List)"
    "center,title:^(Starting Apache NetBeans IDE)$"
    "center,title:.*Bitwarden.*"
    "center,title:^(Import Hyprpanel Theme)$"
    "center,title:^(hyprpanel-settings)$"
    "center,title:^(Hyprland Polkit Agent)$"
    "center,title:^(rofi - )$"
    "center,title:^(rofi -  myamusashi@nixos)$"
    "center,title:^(rofi - APPS)$"
    "center,title:^(Image Properties)$"
    "center,title:^(Enter name of file to save to…)$"
    "center,title:^(vesktop)$"
    "center,class:^(eu.),title:^(Properties|Select icon)"

    # Size rules
    "size 919 437,initialTitle:^(yaziWS)"
	"size 900 710, class:^(zen),title:^(Login - Akun Google - Zen Browser)"
    "size 500 500,class:^(org.freedesktop.impl.portal.desktop.kde)"
    "size 943 800,title:^(Select what to share)"
    "size 885 443,class:^(xdg-desktop-portal-kde),title:^(Open Folder)"
    "size 1000 600,class:^(org.quickshell),title:^(Select a wallpaper)"
    "size 400 300,title:^(WhatsApp — KDE Connect Daemon)"
    "size 360 363,class:^(eu.),title:^(Properties)"
    "size 300 650,title:^(Friends List)"
    "size 622 652,class:^(clipse)"
    "size 380 630,title:.*Bitwarden.*"
    "size 480 300,title:^(Starting Apache NetBeans IDE)$"
    "size 300 350,title:^(vesktop)$"
    "size 954 641,title:^*.Akun Google.*"
    "size 800 600,title:^(hyprpanel-settings)$"
    "size 800 600,title:^(Import Hyprpanel Theme)$"
    "size 800 600,title:^(Hyprland Polkit Agent)$"
    "size 800 600,class:^(download)$"
    "size 800 600,title:^(Volume Control)$"
    "size 493 254,title:^(Image Properties)$"
    "size 505 600,title:^(iwgtk)$"
    "size 885 463,title:^(Enter name of file to save to…)$"
    "size 652 310,title:^(Bluetooth Devices)$"
    "size 370 300,class:^(org.kde.kdeconnect.daemon),title:^(Receiving files)"

    # Misc rules
    "stayfocused,class:^(clipse)"
    "stayfocused,class:^(org.quickshell),title:^(Authentication Required)"
    "stayfocused,initialTitle:^(yaziWS)"

    "idleinhibit focus,class:^(mpv)$"
    "idleinhibit fullscreen,class:^(firefox)$"

    "opacity 0.90,title:^(Spotify)$"
    "opacity 1 override,class:^(zen|zen-twilight|zen-beta)$"
    "opacity 1 override,class:^(vesktop|discord)$"
    "opacity 0.95,class:^(nemo)$"

    # "noblur,xwayland:1"

    "noborder,initialClass:^(Xdg-desktop-portal-gtk)$"
    "noborder,initialClass:^(Xdg-desktop-portal-kde)$"

    "bordersize 0,initialClass:^(Xdg-desktop-portal-gtk)$"
    "bordersize 0,initialClass:^(Xdg-desktop-portal-kde)$"

    # Quickshell window
    "float,class:^(org.quickshell),title:^(Authentication Required)"
    "float,class:^(org.quickshell),title:^(Recording Widgets)"

    # Bottom-right position
    "move 100%-w-20 100%-w-20,class:^(org.quickshell),title:^(Recording Widgets)"

    "center,class:^(org.quickshell),title:^(Authentication Required)"

    "size 530 520,class:^(org.quickshell),title:^(Authentication Required)"
    "size 300 230,class:^(org.quickshell),title:^(Recording Widgets)"

    "noborder,class:^(org.quickshell),title:^(Authentication Required)"
    "noborder,class:^(org.quickshell),title:^(Recording Widgets)"

    "rounding 26,class:^(org.quickshell),title:^(Authentication Required)"
    "rounding 26,class:^(org.quickshell),title:^(Recording Widgets)"
  ];

  layerrule = [
    # Layer blur
    "blur, rofi"
    "blur, launcher"
    "blur, quickshell"
    "blur, shell:dashboard"
    "blur, shell:bigclock"
    "blur, shell:app"
    "blur, shell:bar"
    "blur, shell:capture"
    "blur, shell:session"

    # Layer animation
    "animation popup 30%, quickshell"
    "animation popup 30%, shell:dashboard"
    "animation popup 30%, shell:bigclock"
    "animation popup 90%, selection"
    "animation slide, shell:app"
    "animation slide, shell:bar"
    "animation slide, shell:capture"
    "animation slide, shell:session"
    "animation slide, shell:overview"

    # Layer ignoring zero alpha
    "ignorezero, quickshell"
    "ignorezero, shell:dashboard"
    "ignorezero, shell:bigclock"
    "ignorezero, shell:app"
    "ignorezero, shell:bar"
    "ignorezero, shell:capture"
    "ignorezero, shell:session"
  ];
}
