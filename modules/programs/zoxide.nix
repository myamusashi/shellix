{
    flake.modules.nixos.zoxide = {pkgs, ...}: let
        # Rendered once at build time so shells source a store-immutable file;
        # the database (~/.local/share/zoxide/db.zo) remains mutable state.
        zoxideFishScript = pkgs.runCommand "zoxide-init-fish" {} "${pkgs.zoxide}/bin/zoxide init fish > $out";
        zoxideNushellScript = pkgs.runCommand "zoxide-init-nushell" {} "${pkgs.zoxide}/bin/zoxide init nushell > $out";
    in {
        key = "shellix.nixos.zoxide";

        environment.systemPackages = [pkgs.zoxide];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 - - - -"
            "d %h/.config/fish 0755 - - - -"
            "d %h/.config/fish/conf.d 0755 - - - -"
            "L+ %h/.config/fish/conf.d/30-zoxide.fish - - - - ${zoxideFishScript}"
            "d %h/.config/nushell 0755 - - - -"
            "L+ %h/.config/nushell/zoxide.nu - - - - ${zoxideNushellScript}"
        ];
    };
}
