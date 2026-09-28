{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.zoxide;

    # Rendered once at build time so shells source a store-immutable file.
    # The database itself (~/.local/share/zoxide/db.zo) stays mutable state.
    zoxideFish = pkgs.runCommand "zoxide-init-fish" {} "${pkgs.zoxide}/bin/zoxide init fish > $out";
    zoxideNu =
        pkgs.runCommand "zoxide-init-nushell" {}
        "${pkgs.zoxide}/bin/zoxide init nushell > $out";
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.zoxide];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/fish 0755 myamusashi users - -"
            "d %h/.config/fish/conf.d 0755 myamusashi users - -"
            "L+ %h/.config/fish/conf.d/30-zoxide.fish - - - - ${zoxideFish}"
            "d %h/.config/nushell 0755 myamusashi users - -"
            "L+ %h/.config/nushell/zoxide.nu - - - - ${zoxideNu}"
        ];
    };
}
