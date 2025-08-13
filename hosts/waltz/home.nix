{pkgs-stable, ...}: {
  imports = [
    ../../modules/programs/default.nix
    ../../modules/packages/config.nix
    ../../modules/services/default.nix
  ];

  shellix = {
    programs = {
      enable = true;
      target = "home-manager";
    };

    packages = {
    };

    services = {};
  };

  programs.git = {
    enable = true;
    userName = "myamusashi";
    userEmail = "myamusashi@users.noreply.github.com";
    aliases = {
      ci = "commit";
      sw = "checkout";
      s = "status";
    };
    extraConfig = {
      credential.helper = "${pkgs-stable.git-credential-manager}/bin/git-credential-manager";
    };
    lfs.enable = true;
  };
}
