{pkgs, ...}: {
  services.displayManager.sddm = {
    enable = true;
    theme = "reactionary";
    extraPackages = with pkgs; [
      kdePackages.sddm-kcm
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

  services.desktopManager.plasma6.enable = true;
}
