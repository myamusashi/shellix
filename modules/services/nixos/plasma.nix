{
    lib,
    config,
    pkgs,
    ...
}: {
    config = lib.mkIf config.shellix.services.nixos.plasma.enable {
        services.desktopManager.plasma6.enable = true;
        environment.plasma6.excludePackages = with pkgs; [
            kdePackages.drkonqi
            kdePackages.dolphin
        ];
        programs.dconf.enable = true;

        environment.systemPackages = [
            pkgs.kdePackages.qtstyleplugin-kvantum
            pkgs.kdePackages.qtsvg
            pkgs.kdePackages.plasma-desktop
            pkgs.kdePackages.sddm-kcm
        ];
    };
}
