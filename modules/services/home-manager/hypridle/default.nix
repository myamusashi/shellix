{
    lib,
    config,
    pkgs,
    ...
}: {
    config = lib.mkIf config.shellix.services.home-manager.hypridle.enable {
        services.hypridle = {
            enable = pkgs.lib.mkDefault true;

            settings = {
                general = {
                    lock_cmd = "hyprlock";
                    unlock_cmd = "notify-send 'woilah cik'";
                };

                listener = [
                    {
                        timeout = 200;
                        on-timeout = "${pkgs.wl-gammactl}/bin/wl-gammactl -c 0.5";
                        on-resume = "pkill wl-gammactl";
                    }

                    {
                        timeout = 1500;
                        on-timeout = "pkill wl-gammactl && ${pkgs.wl-gammactl}/bin/wl-gammactl -c 0.1 && notify-send -a 'Hypridle' 'Idle' 'Bangun woy, gua kunci nih' -i sleep";
                        on-resume = "pkill wl-gammactl";
                    }

                    {
                        timeout = 1800;
                        on-timeout = "shell ipc call lock lock";
                    }
                ];
            };
        };
    };
}
