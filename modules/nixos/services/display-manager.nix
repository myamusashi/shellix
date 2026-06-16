{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.services.display-manager;
in {
    config = lib.mkMerge [
        (lib.mkIf (cfg.greetd.enable && cfg.sddm.enable) {
            assertions = [
                {
                    assertion = false;
                    message = "Cannot enable both greetd and sddm simultaneously";
                }
            ];
        })

        (lib.mkIf cfg.greetd.enable {
            services.greetd = {
                enable = true;
                inherit (cfg.greetd) package;
                vt = cfg.greetd.virtual-console;
                settings = {
                    initial_session = lib.mkIf cfg.greetd.auto-login.enable {
                        command = cfg.greetd.auto-login.runner;
                        inherit (cfg.greetd.auto-login) user;
                    };
                    default_session = {
                        command = let
                            greeterPkg = pkgs.${cfg.greetd.greeter} or pkgs.greetd.tuigreet;
                            greeterBin = "${greeterPkg}/bin/${cfg.greetd.greeter}";
                            flagsStr = lib.concatStringsSep " " cfg.greetd.flags;
                        in "${greeterBin} ${flagsStr}";
                        user = "greeter";
                    };
                };
            };
        })

        (lib.mkIf cfg.sddm.enable {
            services.displayManager.sddm = {
                enable = true;
                wayland = lib.mkIf cfg.sddm.wayland.enable {
                    enable = true;
                    inherit (cfg.sddm.wayland) compositor;
                };
                theme = lib.mkIf (cfg.sddm.theme != "") cfg.sddm.theme;
                settings = {
                    Autologin = lib.mkIf cfg.sddm.auto-login.enable {
                        Session = cfg.sddm.auto-login.session;
                        User = cfg.sddm.auto-login.user;
                    };
                };
            };
        })
    ];
}
