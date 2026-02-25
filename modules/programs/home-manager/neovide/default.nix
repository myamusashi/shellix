{
    pkgs,
    lib,
    config,
    ...
}: let
    cfg = config.shellix.programs.home.neovide;
in {
    config = lib.mkIf cfg.enable {
        programs.neovide = {
            enable = pkgs.lib.mkDefault true;
            settings = {
                vsync = false;
                srgb = true;
                neovim-bin = "nvim";
            };
        };
    };
}
