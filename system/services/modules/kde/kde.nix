{pkgs, ...}: {
  services.displayManager.sddm = {
    enable = false;
    theme = "reactionary";
    extraPackages = with pkgs; [
      kdePackages.sddm-kcm
      kdePackages.qt6ct
      kdePackages.qt5compat
      libsForQt5.qt5.qtquickcontrols
      kdePackages.kcalc
      kdePackages.kcharselect
      kdePackages.kcolorchooser
      kdePackages.ksystemlog
      kdePackages.isoimagewriter
      kdePackages.partitionmanager
      kdePackages.dolphin
      kdePackages.kate
    ];
    wayland.enable = true;
    # settings = {
    #   Autologin = {
    #     Session = "hyprland.desktop";
    #     User = "myamusashi";
    #   };
    # };
  };

  environment.plasma6.excludePackages = [pkgs.kdePackages.drkonqi];
  programs.dconf.enable = true;
  services.desktopManager.plasma6.enable = true;
}
