{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.cachyosKernels.linux-cachyos-server;
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
    fsType = "ntfs-3g";
    options = ["noatime" "rw" "uid=1000" "gid=100"];
  };
  fileSystems."/opt/backup" = {
    device = "/home/waltz/external";
    options = ["bind"];
  };
}
