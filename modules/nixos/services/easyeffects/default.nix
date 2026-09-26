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

        systemd.user = {
            tmpfiles.rules = [
                "d %h/.local/share/easyeffects 0755 myamusashi users - -"
                "d %h/.local/share/easyeffects/output 0755 myamusashi users - -"
                "L+ %h/.local/share/easyeffects/output/earphone-wired.json - - - - ${pkgs.writeText "earphone-wired.json" (builtins.toJSON presets.earphone-wired)}"
                "L+ %h/.local/share/easyeffects/output/gentle-dynamics.json - - - - ${pkgs.writeText "gentle-dynamics.json" (builtins.toJSON presets.gentle-dynamics)}"
            ];
            services = {
                easyeffects = {
                    description = "EasyEffects daemon";
                    wantedBy = ["graphical-session.target"];
                    after = ["graphical-session.target"];
                    partOf = ["graphical-session.target"];

                    serviceConfig = {
                        Type = "simple";
                        ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
                        ExecStartPost = "${pkgs.coreutils}/bin/sleep 2";
                        Restart = "on-failure";
                    };
                };
                easyeffects-load-preset = {
                    description = "Load EasyEffects preset";
                    after = ["easyeffects.service"];
                    bindsTo = ["easyeffects.service"];
                    wantedBy = ["graphical-session.target"];

                    serviceConfig = {
                        Type = "oneshot";
                        ExecStart = "${pkgs.easyeffects}/bin/easyeffects -l ${cfg.preset}";
                    };
                };
            };
        };
    };
}
