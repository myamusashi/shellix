{pkgs, ...}: {
  home = {
    username = "myamusashi";
    homeDirectory = "/home/myamusashi";
    stateVersion = "24.11";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = ["Hack"];
      monospace = ["Hack"];
      sansSerif = ["Inconsolata LGC Nerd Font"];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default = "hyprland;gtk";
      pantheon.default = "kde";
      gtk.default = "gtk";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
