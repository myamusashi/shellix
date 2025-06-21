{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "myamusashi";
    userEmail = "myamusashi@proton.me";
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
