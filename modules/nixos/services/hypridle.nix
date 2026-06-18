{
    config,
    pkgs,
    lib,
    ...
}: let
    cfg = config.shellix.services.hypridle;
    hypridleConf = ''
        general {
            lock_cmd = hyprlock
            unlock_cmd = notify-send 'woilah cik'
        }

        listener {
            timeout = 200
            on-timeout = ${pkgs.wl-gammactl}/bin/wl-gammactl -c 0.5
            on-resume = pkill wl-gammactl
        }

        listener {
            timeout = 1500
            on-timeout = pkill wl-gammactl && ${pkgs.wl-gammactl}/bin/wl-gammactl -c 0.1 && notify-send -a 'Hypridle' 'Idle' 'Bangun woy, gua kunci nih' -i sleep
            on-resume = pkill wl-gammactl
        }

        listener {
            timeout = 1800
            on-timeout = shell ipc call lock lock
        }
    '';
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.hypridle];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/hypr 0755 myamusashi users - -"
            "L+ %h/.config/hypr/hypridle.conf - - - - ${pkgs.writeText "hypridle.conf" hypridleConf}"
        ];

        systemd.user.services.hypridle = {
            description = "Hyprland idle daemon";
            after = ["graphical-session.target"];
            partOf = ["graphical-session.target"];
            wantedBy = ["graphical-session.target"];

            serviceConfig = {
                ExecStart = "${pkgs.hypridle}/bin/hypridle";
                Restart = "on-failure";
                Slice = "app-graphical.slice";
            };
        };
    };
}
