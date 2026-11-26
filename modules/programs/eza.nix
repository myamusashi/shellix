{
    flake.modules.nixos.eza = {pkgs, ...}: {
        environment.systemPackages = [pkgs.eza];
    };
}
