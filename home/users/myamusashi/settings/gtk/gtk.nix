{pkgs, ...}: let
  vimix-icon = pkgs.callPackage ./icons/vimix-icon-themes/package.nix {colorVariants = ["Ruby"];};
  future-cyan-hyprcursor = pkgs.callPackage ./themes/cursors/Future-cyan-hyprcursor/package.nix {};
  future-cursor = pkgs.callPackage ./themes/cursors/future-cursor/package.nix {};
in {
  home.packages = [
    pkgs.gtk-engine-murrine
    pkgs.gnome-themes-extra
    pkgs.gtk3
    pkgs.gtk4
    future-cyan-hyprcursor
    pkgs.morewaita-icon-theme
    vimix-icon
    pkgs.kdePackages.qt6ct
    pkgs.kanagawa-gtk-theme
    pkgs.kanagawa-icon-theme
    # pkgs.vimix-icon-theme
    # pkgs.numix-icon-theme
    pkgs.papirus-icon-theme
    pkgs.kdePackages.qtstyleplugin-kvantum
    (pkgs.whitesur-kde.override {
      })
    (pkgs.whitesur-icon-theme.override {
      themeVariants = ["default"];
    })
    (pkgs.whitesur-gtk-theme.override {
      themeVariants = ["blue"];
      colorVariants = ["dark"];
      darkerColor = true;
    })
    (pkgs.vimix-gtk-themes.override {
      themeVariants = ["ruby"];
      colorVariants = ["dark"];
      sizeVariants = ["standard"];
      tweaks = ["translucent"];
    })
  ];

  home.pointerCursor = {
    package = future-cursor;
    name = "Future-cursors";
    size = 40;
    gtk.enable = true;
    x11.enable = true;
  };

  qt = {
    enable = true;
    style = {
      name = "kvantum";
    };
  };

  gtk = {
    enable = true;

    iconTheme = {name = "WhiteSur-dark";};
    theme = {name = "WhiteSur-Dark-blue";};

    gtk3 = {
      extraConfig = {
        "gtk-application-prefer-dark-theme" = 1;
        "gtk-enable-event-sounds" = 1;
        "gtk-enable-input-feedback-sounds" = 0;
        "gtk-xft-antialias" = 1;
        "gtk-xft-hinting" = 1;
        "gtk-xft-hintstyle" = "hintslight";
        "gtk-xft-rgba" = "rgb";
      };
    };
    gtk4 = {
      extraConfig = {"gtk-application-prefer-dark-theme" = 1;};
    };
  };
}
