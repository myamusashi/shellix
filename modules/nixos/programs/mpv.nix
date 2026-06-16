{
    lib,
    config,
    pkgs,
    ...
}: let
    cfg = config.shellix.programs.mpv;
    mpvConf = ''
        # Hardware decoding
        hwdec = auto-safe
        hwdec-codecs = all

        # Lower quality scaling
        profile = fast
        scale = bilinear
        dscale = bilinear
        cscale = bilinear

        # Disable expensive features
        vo = gpu
        gpu-api = auto
        deband = no
        dither-depth = no

        # Frame dropping
        framedrop = vo

        # Reduce cache
        cache = yes
        demuxer-max-bytes = 50M
        demuxer-max-back-bytes = 10M
    '';
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.mpv];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/mpv 0755 myamusashi users - -"
            "L+ %h/.config/mpv/mpv.conf - - - - ${pkgs.writeText "mpv.conf" mpvConf}"
        ];
    };
}
