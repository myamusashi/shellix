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
        supportedFilesystems = ["ntfs"];
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
            # Default podman subnet 10.88.0.0/16 collides with WireGuard 10.88.0.0/24 (wg0 = 10.88.0.1).
            # Move podman0 far away so it never claims the WG gateway IP; per-job
            # bridges (10.89.x) are unaffected. BIND-mode Pi-hole then leaves their :53 free.
            defaultNetwork.settings = {
                dns_enabled = true;
                subnets = [
                    {
                        gateway = "10.94.0.1";
                        subnet = "10.94.0.0/16";
                    }
                ];
            };
        };
    };

    fileSystems."/home/waltz/external" = {
        device = "/dev/disk/by-label/BACKUP";
        fsType = "ntfs";
        options = [
            "noatime"
            "nofail"
            "rw"
            "uid=1000"
            "gid=100"
        ];
    };

    fileSystems."/opt/backup" = {
        device = "/home/waltz/external";
        fsType = "none";
        options = [
            "bind"
            "nofail"
            "x-systemd.requires-mounts-for=/home/waltz/external"
        ];
    };

    fileSystems."/".options = [ "noatime" ];
}
