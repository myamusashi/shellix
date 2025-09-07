{
  lib,
  stdenvNoCC,
  unzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "14-segment-led";
  version = "0.1";

  src = ./14-segment-led.zip;

  nativeBuildInputs = [unzip];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype/${pname}
    install -Dm644 *.ttf $out/share/fonts/truetype/${pname}/
    runHook postInstall
  '';

  meta = with lib; {
    description = "";
    homepage = "";
    license = lib.licenses.unfree;
    maintainers = with maintainers; [myamusashi];
  };
}
