{
    lib,
    config,
    pkgs,
    inputs,
    ...
}: {
    # imports = [
    #     inputs.aerothemeplasma-nix.nixosModules.aerothemeplasma-nix
    # ];

    config = lib.mkIf config.shellix.services.plasma.enable {
        services.desktopManager.plasma6.enable = true;
        # services.displayManager.defaultSession = "aerothemeplasma";
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

        # programs.aeroshell = {
        #     enable = true;
        #     fonts.segoe.enable = true;
        #     polkit.enable = true;
        #     aerothemeplasma = {
        #         enable = true;
        #         sddm.enable = true;
        #         plymouth.enable = true;
        #     };
        # };
    };
}
