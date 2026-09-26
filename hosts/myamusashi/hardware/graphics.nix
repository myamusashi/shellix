{pkgs, ...}: {
    hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
            vulkan-loader
            intel-media-driver
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
            intel-media-driver
        ];
    };
}
