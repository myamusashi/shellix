{
    stdenv,
    fetchurl,
    makeWrapper,
    autoPatchelfHook,
    zstd,
    glib,
    gtk4,
    webkitgtk_6_0,
    gst_all_1,
    alsa-lib,
}: let
    pname = "serein";
    version = "1.0.0-nightly.10.1";
in
    stdenv.mkDerivation {
        inherit pname version;

        src = fetchurl {
            url = "https://github.com/ViceVerse-cz/Serein/releases/download/v${version}/serein-v${version}-Linux-arch-serein-1.0.0pre.nightly.10.1-1-x86_64.pkg.tar.zst";
            hash = "sha256-RH+i1JN1A69sTn6uLZRvg2AyN/x2jqtKTyE/y6+0RPw=";
        };

        nativeBuildInputs = [
            makeWrapper
            autoPatchelfHook
            zstd
        ];

        buildInputs = [
            webkitgtk_6_0
            glib
            gtk4
            gst_all_1.gst-plugins-base
            alsa-lib
        ];

        sourceRoot = ".";

        installPhase = ''
            runHook preInstall

            mkdir -p $out

            if [ -d "usr" ]; then
                cp -r usr/* $out/
            else
                mkdir -p $out/bin $out/share
                [ -d "bin" ] && cp -r bin/* $out/bin/
                [ -d "share" ] && cp -r share/* $out/share/
            fi

            runHook postInstall
        '';
    }
