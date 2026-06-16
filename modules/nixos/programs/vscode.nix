{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.vscode;
    vscodiumPkg = pkgs.vscodium.override {
        commandLineArgs = "--enable-features=Vulkan,VaapiVideoDecodeLinuxGL,VaapiIgnoreDriverChecks,VaapiVideoDecoder,VaapiVideoEncoder,AcceleratedVideoEncoder,UseMultiPlaneFormatForHardwareVideo,SkiaGraphite --ignore-gpu-blocklist --enable-zero-copy";
    };
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [vscodiumPkg];
    };
}
