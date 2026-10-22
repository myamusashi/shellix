{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.starship;

    starshipNu =
        pkgs.runCommand "starship-init-nushell" {}
        "${pkgs.starship}/bin/starship init nu > $out";
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.starship];

        programs.fish.interactiveShellInit = lib.mkAfter ''
            if command -q starship
                starship init fish | source
            end
        '';

        systemd.user.tmpfiles.rules = [
            "d %h/.local/share 0755 myamusashi users - -"
            "d %h/.local/share/nushell 0755 myamusashi users - -"
            "d %h/.local/share/nushell/vendor 0755 myamusashi users - -"
            "d %h/.local/share/nushell/vendor/autoload 0755 myamusashi users - -"
            "L+ %h/.local/share/nushell/vendor/autoload/starship.nu - - - - ${starshipNu}"
        ];
    };
}
