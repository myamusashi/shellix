{
    lib,
    stdenv,
    unzip,
}:
stdenv.mkDerivation {
    pname = "google-sans-flex";
    version = "1.0";

    src = ../assets/fonts/Google_Sans_Flex_Inter.zip;

    buildInputs = [
        unzip
    ];

    unpackPhase = ''
        unzip $src
    '';

    installPhase = ''
        runHook preInstall

        install -Dm644 Google_Sans_Flex_Inter/Google_Sans_Flex/*.ttf -t $out/share/fonts/truetype

        runHook postInstall
    '';

    meta = with lib; {
        description = "Google Sans Flex font family";
        platforms = platforms.all;
    };
}
