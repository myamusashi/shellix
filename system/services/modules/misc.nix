{pkgs, ...}: {
  services = {
    cloudflare-warp.enable = false;
    gnome.gnome-keyring.enable = true;
    scx.enable = true;
    fwupd.enable = true;
    throttled.enable = true;

    printing.enable = false;
    udisks2.enable = true;

    gvfs.enable = false;

    flatpak.enable = false;

    blueman.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    openssh.enable = true;

    locate = {
      enable = true;
      package = pkgs.mlocate;
    };

    earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemKillThreshold = 2;
      freeSwapKillThreshold = 3;
    };

    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
  };

  systemd.services."getty@tty2".enable = false;
}
