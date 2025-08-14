{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_cachyos-server;
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

  fileSystems."/opt/backup" = {
    device = "/dev/disk/by-label/BACKUP";
    fsType = "ext4";
    options = ["noatime"];
  };
}
