{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.home.vscode;
in {
    config = lib.mkIf cfg.enable {
        programs.vscode = {
            enable = true;
            package = pkgs.vscodium.override {
                commandLineArgs = "--enable-features=Vulkan,VaapiVideoDecodeLinuxGL,VaapiIgnoreDriverChecks,VaapiVideoDecoder,VaapiVideoEncoder,AcceleratedVideoEncoder,UseMultiPlaneFormatForHardwareVideo,SkiaGraphite --ignore-gpu-blocklist --enable-zero-copy";
            };
            profiles.default = {
                enableExtensionUpdateCheck = true;
                enableUpdateCheck = true;
            };
        };
    };
}
