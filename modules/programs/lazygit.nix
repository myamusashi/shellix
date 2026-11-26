{
    flake.modules.nixos.lazygit = {pkgs, ...}: {
        environment.systemPackages = [pkgs.lazygit];
    };
}
