{
    config,
    pkgs,
    lib,
    ...
}: let
    cfg = config.shellix.services.easyeffects;
    loadPreset = name: builtins.fromJSON (builtins.readFile ./presets/${name}.json);

    presets = {
        earphone-wired = loadPreset "earphone-wired";
        gentle-dynamics = loadPreset "gentle-dynamics";
    };
in {
    options.shellix.services.easyeffects.preset = lib.mkOption {
        type = lib.types.enum (builtins.attrNames presets);
        default = "earphone-wired";
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.easyeffects];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/easyeffects 0755 myamusashi users - -"
            "d %h/.config/easyeffects/output 0755 myamusashi users - -"
            "L+ %h/.config/easyeffects/output/earphone-wired.json - - - - ${pkgs.writeText "earphone-wired.json" (builtins.toJSON presets.earphone-wired)}"
            "L+ %h/.config/easyeffects/output/gentle-dynamics.json - - - - ${pkgs.writeText "gentle-dynamics.json" (builtins.toJSON presets.gentle-dynamics)}"
        ];

        systemd.user.services.easyeffects = {
            description = "EasyEffects daemon";
            wantedBy = ["graphical-session.target"];
            after = ["graphical-session.target"];
            partOf = ["graphical-session.target"];

            serviceConfig = {
                BusName = "com.github.wwmm.easyeffects";
                ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
                ExecStartPost = "${pkgs.coreutils}/bin/sleep 2.0; ${pkgs.easyeffects}/bin/easyeffects -l ${cfg.preset}";
                Restart = "on-failure";
            };
        };
    };
}
