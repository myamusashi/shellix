{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.fastfetch;
    configJson = builtins.toJSON {
        logo = {
            type = "kitty";
            source = "/home/myamusashi/.config/fastfetch/maxwell_rembg_optimize.gif";
            width = 15;
            height = 5;
            animationFrame = 0;
        };
        modules = [
            "title"
            "separator"
            "os"
            "host"
            "bios"
            "kernel"
            "shell"
        ];
    };
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.fastfetch];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/fastfetch 0755 myamusashi users - -"
            "L+ %h/.config/fastfetch/config.jsonc - - - - ${pkgs.writeText "fastfetch-config" configJson}"
        ];
    };
}
