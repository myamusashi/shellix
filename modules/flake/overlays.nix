{
    flake.overlays = {
        hotfixes = import ../../overlays/hotfixes.nix;
        packages = import ../../overlays/packages.nix;
        vmware = import ../../overlays/vmware.nix;
        default = import ../../overlays/default.nix;
    };
}
