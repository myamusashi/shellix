flakeParts: let
    flakeConfig = flakeParts.config;
in {
    flake.modules.nixos.easyeffects = {
        config,
        lib,
        pkgs,
        ...
    }: let
        easyeffectsConfig = config.shellix.easyeffects;
        presetNames = [
            "earphone-wired"
            "gentle-dynamics"
        ];
    in {
        key = "shellix.nixos.easyeffects";

        imports = [
            flakeConfig.flake.modules.nixos.audio
        ];

        options.shellix.easyeffects.preset = lib.mkOption {
            type = lib.types.enum presetNames;
            default = "earphone-wired";
            description = "EasyEffects output preset loaded on session startup.";
        };

        config = {
            environment.systemPackages = [pkgs.easyeffects];

            systemd.user = {
                tmpfiles.rules = [
                    "d %h/.local/share/easyeffects 0755 - - - -"
                    "d %h/.local/share/easyeffects/output 0755 - - - -"
                    "L+ %h/.local/share/easyeffects/output/earphone-wired.json - - - - ${../../assets/easyeffects/earphone-wired.json}"
                    "L+ %h/.local/share/easyeffects/output/gentle-dynamics.json - - - - ${../../assets/easyeffects/gentle-dynamics.json}"
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
                            ExecStart = "${pkgs.easyeffects}/bin/easyeffects -l ${easyeffectsConfig.preset}";
                        };
                    };
                };
            };
        };
    };
}
