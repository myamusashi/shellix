{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.starship;

    # Rendered at build time so nushell autoloads a store path instead of
    # regenerating ~/.local/share/nushell/vendor/autoload/starship.nu on
    # every shell start. `starship init nu` bakes the invoking binary path
    # into the snippet, so the store path is pinned to this build.
    starshipNu =
        pkgs.runCommand "starship-init-nushell" {}
        "${pkgs.starship}/bin/starship init nu > $out";
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.starship];

        # ~/.config/starship.toml itself stays owned by the matugen module
        # (templates/starship/starship.colors) so prompt colors track the
        # wallpaper. Nushell autoloads the snippet below; fish needs a hook.
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
