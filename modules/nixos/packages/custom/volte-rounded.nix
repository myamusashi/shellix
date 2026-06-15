{
    lib,
    stdenvNoCC,
    fetchzip,
}:
stdenvNoCC.mkDerivation rec {
    pname = "volte-rounded";
    version = "1.0";

    src = fetchzip {
        url = "https://files.blogfonts.com/v/541/254541/volte-rounded.zip";
        hash = "sha256-1vYdvDNFBWxTs41MHJDsMox2sx/lQQWRTl3/MUuHYPc=";
        stripRoot = false;
    };

    installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fonts/otf/
        install -Dm644 $src/*.otf -t $out/share/fonts/otf/

        runHook postInstall
    '';

    meta = with lib; {
        description = "";
        homepage = "";
        maintainers = [myamusashi];
    };
}
