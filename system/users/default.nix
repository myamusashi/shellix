{pkgs, ...}: {
  programs.fish.enable = true;

  users.users.myamusashi = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "podman"
      "libvirtd"
      "qemu-libvirtd"
      "kvm"
      "video"
      "input"
      "wireshark"
    ];
  };

  users.groups.ubridge = {};
}
