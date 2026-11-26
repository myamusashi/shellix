{
    flake.modules.nixos.mpv = {pkgs, ...}: let
        configurationText = ''
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
        environment.systemPackages = [pkgs.mpv];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 - - - -"
            "d %h/.config/mpv 0755 - - - -"
            "L+ %h/.config/mpv/mpv.conf - - - - ${pkgs.writeText "mpv.conf" configurationText}"
        ];
    };
}
