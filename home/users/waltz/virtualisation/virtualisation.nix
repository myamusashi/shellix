{pkgs-stable, ...}: {
  virtualisation = {
    libvirtd.enable = true;
    docker = {
      enable = false;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    ## Replacement for docker
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings = {dns_enabled = true;};
    };
  };

  ## UEFI fw support
  systemd.tmpfiles.rules = ["L+ /var/lib/qemu/firmware - - - - ${pkgs-stable.qemu}/share/qemu/firmware"];
}
