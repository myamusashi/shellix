{
    flake.modules.nixos.starship = {
        lib,
        pkgs,
        ...
    }: let
        starshipNushellScript = pkgs.runCommand "starship-init-nushell" {} "${pkgs.starship}/bin/starship init nu > $out";
    in {
        environment.systemPackages = [pkgs.starship];

        programs.fish.interactiveShellInit = lib.mkAfter ''
            if command -q starship
                starship init fish | source
            end
        '';

        systemd.user.tmpfiles.rules = [
            "d %h/.local/share 0755 - - - -"
            "d %h/.local/share/nushell 0755 - - - -"
            "d %h/.local/share/nushell/vendor 0755 - - - -"
            "d %h/.local/share/nushell/vendor/autoload 0755 - - - -"
            "L+ %h/.local/share/nushell/vendor/autoload/starship.nu - - - - ${starshipNushellScript}"
        ];
    };
}
