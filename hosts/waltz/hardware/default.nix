{pkgs-stable, ...}: {
    imports = [
        ./hardware-configuration.nix
    ];
    boot = {
        loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = true;
        };
        kernelPackages = pkgs-stable.cachyosKernels.linuxPackages-cachyos-server;
        supportedFilesystems = ["ntfs3"];
    };

    hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs-stable; [
            intel-media-driver
            intel-vaapi-driver
            libva-vdpau-driver
            libva
            libvdpau-va-gl
        ];
        extraPackages32 = with pkgs-stable.pkgsi686Linux; [
            intel-media-driver
            intel-vaapi-driver
        ];
    };

    virtualisation = {
        libvirtd.enable = false;
        docker.enable = false;

        podman = {
            enable = true;
            dockerCompat = true;
            dockerSocket.enable = true;
            defaultNetwork.settings = {dns_enabled = true;};
        };
    };

    fileSystems."/home/waltz/external" = {
        device = "/dev/disk/by-label/BACKUP";
        fsType = "ntfs3";
        options = ["noatime" "nofail" "rw" "uid=1000" "gid=100"];
    };
    fileSystems."/opt/backup" = {
        device = "/home/waltz/external";
        options = ["bind" "nofail" "x-systemd.requires-mounts-for=/home/waltz/external"];
    };
}
