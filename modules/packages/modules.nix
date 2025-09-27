{
  inputs,
  config,
  pkgs,
  ...
}:
with pkgs; {
  system = [
    vim
    pciutils
    libgdiplus
    polkit
    vulkan-tools
    pinentry
    pinentry-qt
    pinentry-curses
    pinentry-tty
    udisks
    udiskie
    gparted
    libvirt
    upower
    upower-notify
    rich-cli
    power-profiles-daemon
    bluez
    mediainfo
    ouch
    glow
    hexyl
    antiprism
    fzf
  ];

  winapps = [
    dialog
    freerdp3
    inputs.winapps.packages.${system}.winapps
    inputs.winapps.packages.${system}.winapps-launcher
    libnotify
    netavark
    iptables
  ];

  nix-tools = {
    standard = [
      nixd
      alejandra
      statix
      nh
    ];

    full = [
      nixd
      nil
      alejandra
      statix
      nix-diff
      nix-tree
      nix-output-monitor
      nix-du
      vulnix
      deadnix
      nix-update
    ];
  };

  fonts = {
    nerd = with nerd-fonts; [
      caskaydia-mono
      comic-shanns-mono
      proggy-clean-tt
      jetbrains-mono
      inconsolata-lgc
    ];
    external = [
      (callPackage ./custom/avenir-font.nix {})
      (callPackage ./custom/feather-font.nix {})
      (callPackage ./custom/volte-rounded.nix {})
      (callPackage ./custom/_14_segment_led_font.nix {})
      noto-fonts
    ];
  };

  network = [
    inetutils
    wireshark
    networkmanagerapplet
    cloudflared
  ];

  development = {
    code_editor = [zed-editor-fhs neovim neovide];
    containers = [podman-tui podman-compose podman];
    tools = [git gh curl kdiff3];
  };

  security = [pass-wayland bws bitwarden-desktop];

  multimedia = {
    office = [onlyoffice-desktopeditors libreoffice unoconv];
    apps = [telegram-desktop vesktop (config.lib.nixGL.wrap pkgs.vivaldi) vivaldi-ffmpeg-codecs (config.lib.nixGL.wrap inputs.zen-browser.packages.${pkgs.system}.default)];
  };

  gnome = [gnome-keyring];

  gaming = {
    platform = [steam lutris];
    utilities = [
      wine-wayland
      winetricks
      wineWowPackages.waylandFull
      protonup
      protonup-qt
    ];
  };

  android = [adb-sync scrcpy android-tools];

  media = {
    editor = [ffmpeg imagemagick];
    viewer = [ffmpegthumbnailer poppler-utils mpv lxqt.lximage-qt zathura];
    screen_recorder = [obs-studio grim slurp hyprshot wf-recorder];
    misc = [playerctl cava zathura mpg123];
  };

  wayland = {
    core = [wayland-protocols wl-clipboard];
    wallpaper = [swww waypaper hyprpaper];
    launcher = [rofi tofi wofi];
    hyprland = [
      hyprpicker
      hyprland
      hyprsunset
    ];
  };

  theming = with pkgs; {
    colors = [matugen pywal16];
    apps = [pywalfox-native];
    tools = [gtk-engine-murrine gnome-themes-extra kdePackages.qtstyleplugin-kvantum gtk3 gtk4];
    cursors = [
      (callPackage ./custom/future-cursor.nix {})
      (callPackage ./custom/future-cyan-hyprcursor.nix {})
    ];
    icons = [
      papirus-icon-theme
      kanagawa-icon-theme
      vimix-icon-theme
      material-symbols
      morewaita-icon-theme
      (whitesur-icon-theme.override {themeVariants = ["default"];})
    ];
    qt = [whitesur-kde qt6ct hyprqt6engine];
    gtk = [
      (whitesur-gtk-theme.override {
        themeVariants = ["blue"];
        colorVariants = ["dark"];
        darkerColor = true;
      })
      (vimix-gtk-themes.override {
        themeVariants = ["ruby"];
        colorVariants = ["dark"];
        sizeVariants = ["standard"];
        tweaks = ["translucent"];
      })
    ];
  };
}
