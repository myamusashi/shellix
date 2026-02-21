{
    lib,
    config,
    ...
}: let
    cfg = config.shellix.programs.home.mpv;
in {
    config = lib.mkIf cfg.enable {
        programs.mpv = {
            enable = true;
            config = {
                # Hardware decoding
                "hwdec" = "auto-safe";
                "hwdec-codecs" = "all";

                # Lower quality scaling
                "profile" = "fast";
                "scale" = "bilinear";
                "dscale" = "bilinear";
                "cscale" = "bilinear";

                # Disable expensive features
                "vo" = "gpu";
                "gpu-api" = "auto";
                "deband" = "no";
                "dither-depth" = "no";

                # Frame dropping
                "framedrop" = "vo";

                # Reduce cache
                "cache" = "yes";
                "demuxer-max-bytes" = "50M";
                "demuxer-max-back-bytes" = "10M";
            };
            defaultProfiles = [
                "gpu-hq"
            ];
        };
    };
}
