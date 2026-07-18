{pkgs, ...}: {
    imports = [
        "${fetchGit {
            url = "https://github.com/NixOS/nixos-hardware.git";
            rev = "2379bc40992ec29feb1933bb4acd224fa055f3f8";
        }}/lenovo/thinkpad/x270"
        ./bootConfig.nix
        ./hardware-configuration.nix
        ./services.nix
        ./virtualization.nix
    ];

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
            # Graphics stuff
            intel-gpu-tools
            iio-sensor-proxy
            podman-compose
            libva-utils
            virtualgl
            vulkan-tools

            # Hardware and stuff
            pciutils

            # Auto mounts disks
            udisks
            udiskie

            # partition configurations
            gparted

            # Brightness controls
            ddcutil
            wl-gammactl

            # Remote virtualization
            virt-viewer
            freerdp

            # Monitor info
            wlr-randr
        ];
    };

    hardware = {
        sensor.iio.enable = true;

        # needs for ddcutil
        i2c.enable = true;
        acpilight.enable = true;

        bluetooth = {
            enable = true;
            powerOnBoot = true;
        };

        graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
                vulkan-loader
                intel-media-driver
            ];
            extraPackages32 = with pkgs.pkgsi686Linux; [
                intel-media-driver
            ];
        };
    };

    fileSystems."/".options = ["discard"];

    security = {
        wrappers.gsr-kms-server = {
            source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
            capabilities = "cap_sys_admin+ep";
            owner = "root";
            group = "root";
        };

        wrappers.intel_gpu_top = {
            source = "${pkgs.intel-gpu-tools}/bin/intel_gpu_top";
            capabilities = "cap_perfmon+ep";
            owner = "myamusashi";
            group = "root";
        };

        pam.services.greetd.text = ''
            auth      substack      login
            account   include       login
            password  substack      login
            session   include       login
        '';
    };

    zramSwap = {
        enable = true;
        priority = 1;
        algorithm = "zstd";
        memoryPercent = 50;
        memoryMax = null;
    };
    # swapDevices = lib.mkForce [];
}
