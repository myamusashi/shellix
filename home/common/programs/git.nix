{pkgs, ...}: {
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
      credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
    };
    lfs.enable = true;
  };
}
