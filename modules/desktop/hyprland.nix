{inputs, ...}: {
    flake.modules.nixos.hyprland = {pkgs, ...}: let
        system = pkgs.stdenv.hostPlatform.system;
        patchedHyprland = inputs.hyprland.packages.${system}.default.overrideAttrs (previous: {
            patches =
                (previous.patches or [])
                ++ [
                    ../../patches/hyprland-surface-partial-damage.patch
                ];
        });
        # patchedScrollOverview = inputs.hypr-scroll-overview.packages.${system}.default.overrideAttrs (_: {
        #     patches = [../../patches/hyprland-scroll-overview.patch];
        # });
    in {
        key = "shellix.nixos.hyprland";

        imports = [
            inputs.hyprland.nixosModules.default
        ];

        programs.hyprland = {
            enable = true;
            package = patchedHyprland;
            portalPackage = inputs.xdg-desktop-portal-hyprland.packages.${system}.default;
        };

        environment.systemPackages = with pkgs; [
            wl-clipboard
            hyprpicker
            hyprsunset
            # patchedScrollOverview
            inputs.hypr-dynamic-cursors.packages.${system}.hypr-dynamic-cursors
        ];

        xdg.portal = {
            enable = true;
            extraPortals = [
                pkgs.xdg-desktop-portal-gtk
                inputs.myamusashi-pkgs.packages.${system}.loaf-fm
            ];
            config = {
                common.default = ["gtk"];
                hyprland = {
                    default = ["hyprland"];
                    "org.freedesktop.impl.portal.FileChooser" = ["loaf"];
                    "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
                    "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
                    "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
                };
            };
        };
    };
}
