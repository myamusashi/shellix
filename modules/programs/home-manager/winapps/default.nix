{
    config,
    pkgs,
    lib,
    ...
}: let
    cfg = config.shellix.programs.home.winapps;
in {
    config = lib.mkIf cfg.enable {
        home.file.".config/winapps/winapps.conf" = {
            enable = true;
            text = ''
                # [WINDOWS USERNAME]
                RDP_USER="myamusashi"

                # [WINDOWS PASSWORD]
                RDP_PASS="123"

                # [WINDOWS DOMAIN]
                RDP_DOMAIN=""

                # [WINDOWS IPV4 ADDRESS]
                RDP_IP="127.0.0.1"

                # [VM NAME]
                VM_NAME="RDPWindows"

                # [WINAPPS BACKEND]
                WAFLAVOR="podman"

                # [DISPLAY SCALING FACTOR]
                RDP_SCALE="100"

                # [MOUNTING REMOVABLE PATHS FOR FILES]
                # NOTES:
                # - By default, `udisks` (which you most likely have installed) uses /run/media for mounting removable devices.
                #   This improves compatibility with most desktop environments (DEs).
                # ATTENTION: The Filesystem Hierarchy Standard (FHS) recommends /media instead. Verify your system's configuration.
                # - To manually mount devices, you may optionally use /mnt.
                # REFERENCE: https://wiki.archlinux.org/title/Udisks#Mount_to_/media
                REMOVABLE_MEDIA="/run/media"

                # [ADDITIONAL FREERDP FLAGS & ARGUMENTS]
                # NOTES:
                # - You can try adding /network:lan to these flags in order to increase performance, however, some users have faced issues with this.
                # DEFAULT VALUE: '/cert:tofu /sound /microphone +home-drive'
                # VALID VALUES: See https://github.com/awakecoding/FreeRDP-Manuals/blob/master/User/FreeRDP-User-Manual.markdown
                RDP_FLAGS="/cert:tofi /multimon /w:100% /h:100%  /sound +home-drive"

                # [DEBUG WINAPPS]
                DEBUG="true"

                # [AUTOMATICALLY PAUSE WINDOWS]
                AUTOPAUSE="off"

                # [AUTOMATICALLY PAUSE WINDOWS TIMEOUT]
                AUTOPAUSE_TIME="300"

                # [FREERDP COMMAND]
                FREERDP_COMMAND="${pkgs.freerdp}/bin/xfreerdp"

                # [TIMEOUTS]
                # NOTES:
                # - These settings control various timeout durations within the WinApps setup.
                # - Increasing the timeouts is only necessary if the corresponding errors occur.
                # - Ensure you have followed all the Troubleshooting Tips in the error message first.

                PORT_TIMEOUT="5"
                RDP_TIMEOUT="30"
                APP_SCAN_TIMEOUT="60"
                BOOT_TIMEOUT="120"

                HIDEF="on"
            '';
        };
    };
}
