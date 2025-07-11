{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    mouse = true;
    shell = "${pkgs.fish}/bin/fish";
  };
}
