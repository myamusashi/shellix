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

  services.desktopManager.plasma6.enable = true;
}
