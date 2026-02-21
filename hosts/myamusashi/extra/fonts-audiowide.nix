{
    lib,
    stdenvNoCC,
    unzip,
}:
stdenvNoCC.mkDerivation {
    pname = "audiowide";
    version = "1.1";

    src = ./files/Audiowide.zip;

    buildInputs = [
        unzip
    ];

    unpackPhase = ''
        unzip $src
    '';

    installPhase = ''
        runHook preInstall

        install -Dm644 *.ttf -t $out/share/fonts/TTF

        runHook postInstall
    '';

    meta = {
        description = "I like this one";
        maintainers = with lib.maintainers; [myamusashi];
        platforms = with lib.platforms; all;
        homepage = "";
        license = lib.licenses.ofl;
    };
}
