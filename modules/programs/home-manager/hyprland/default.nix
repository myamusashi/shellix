{
    lib,
    config,
    pkgs,
    inputs,
    ...
}: let
    cfg = config.shellix.programs.home.hyprland;
in {
    options.shellix.programs.home.hyprland = {
        plugins = {
            enable = lib.mkEnableOption "Enable hyprland plugin systems";
            hy3 = {
                enable = lib.mkEnableOption "Enable hy3 hyprland i3 like plugins";
                keybind = lib.mkEnableOption "Enable default keybinding";
            };

            hypr-dynamic-cursors = {
                enable = lib.mkEnableOption "Enable dynamic cursors";
            };
        };
    };

    config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland = {
            enable = lib.mkDefault true;
            plugins = [
                # (lib.mkIf cfg.plugins.hypr-dynamic-cursors.enable "${inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors}/lib/libhypr-dynamic-cursors.so")
            ];

            importantPrefixes = [
                "$"
                "source"
                "output"
                "bezier"
                "name"
            ];
            settings = import ./config {inherit pkgs config inputs lib;};
        };
    };
}
