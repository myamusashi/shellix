{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.neovide;
    neovideConfig = ''
        vsync = false
        srgb = true
        neovim-bin = "nvim"
    '';
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.neovide];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/neovide 0755 myamusashi users - -"
            "L+ %h/.config/neovide/config.toml - - - - ${pkgs.writeText "neovide-config" neovideConfig}"
        ];
    };
}
