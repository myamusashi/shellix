{pkgs, ...}: {
    environment = {
        etc = {
            "icc/thinkpad-x270.icm" = {
                source = ./thinkpad_270_icc.icm;
            };
            "icc/lg-mk400.icm" = {
                source = ./lg_mk400_icc.icm;
            };
        };
        systemPackages = with pkgs; [
            intel-gpu-tools
            iio-sensor-proxy
            podman-compose
            libva-utils
            virtualgl
            vulkan-tools
            pciutils
            udisks
            udiskie
            gparted
            ddcutil
            wl-gammactl
            virt-viewer
            freerdp
            wlr-randr
        ];
    };
}
