{
    lib,
    stdenvNoCC,
    fetchzip,
}:
stdenvNoCC.mkDerivation rec {
    pname = "switzer";
    version = "2.0";

    src = fetchzip {
        url = "https://api.fontshare.com/v2/fonts/download/switzer";
        hash = "sha256-GqpIAbGQox2iekGDhgPZXwjR0KXY3AAWzeCT7k5HkmU=";
        extension = "zip";
        stripRoot = false;
    };

    installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fonts/opentype/${pname}
        mkdir -p $out/share/fonts/truetype/${pname}
        install -Dm644 $src/Switzer_Complete/Fonts/OTF/*.otf -t $out/share/fonts/opentype/${pname}/
        install -Dm644 $src/Switzer_Complete/Fonts/TTF/*.ttf -t $out/share/fonts/truetype/${pname}/

        runHook postInstall
    '';

    meta = with lib; {
        description = "";
        homepage = "https://www.fontshare.com/fonts/switzer";
        maintainers = [myamusashi];
    };
}
