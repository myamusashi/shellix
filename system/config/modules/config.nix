{
  pkgs,
  nixgl,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  # Nuh uh, don't fucking changing it
  system.stateVersion = "24.11"; # Did you read the comment?

  fonts.fontDir.enable = true;

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    hyprland.enable = true;
    ccache.enable = true;
    java = {
      enable = true;
      package = pkgs.jdk23;
    };
  };

  environment.etc = {
    "qemu/myamusashi.conf" = {
      text = "allow all";
      user = "root";
      group = "root";
      mode = "0640";
    };

    "qemu/bridge.conf" = {
      text = ''
        include /etc/qemu/myamusashi.conf
      '';
      user = "myamusashi";
      group = "root";
      mode = "0640";
    };
  };
}
