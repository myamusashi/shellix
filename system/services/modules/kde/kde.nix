{pkgs, ...}: {
  services.displayManager.sddm = {
    enable = false;
    theme = "WhiteSur-dark";
    extraPackages = with pkgs; [
      kdePackages.plasma-desktop
      kdePackages.qtsvg
      kdePackages.sddm-kcm
    ];
    wayland.enable = true;
  };

  environment.plasma6.excludePackages = with pkgs; [kdePackages.drkonqi];
  programs.dconf.enable = true;
  services.desktopManager.plasma6.enable = true;
}
