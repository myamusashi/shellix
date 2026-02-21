{
    lib,
    stdenvNoCC,
    hicolor-icon-theme,
    fetchFromBitbucket,
}: let
    pname = "yet-another-monochrome-icon-set";
in
    stdenvNoCC.mkDerivation rec {
        inherit pname;
        version = "2025-09-19-stable";

        src = fetchFromBitbucket {
            owner = "dirn-typo";
            repo = pname;
            rev = "7861dd16f981544cd5c5ab3fac6dec19b3e4714b";
            hash = "sha256-o0s9zcXRk8WTJAqztfDl2ccGIgJbREAqIJKLb6lgsFs=";
        };

        propagatedBuildInputs = [
            hicolor-icon-theme
        ];

        dontDropIconThemeCache = true;
        dontCheckForBrokenSymlinks = true;

        installPhase = ''
            runHook preInstall

            mkdir -p $out/share/icons/${pname}
            cp -pr * $out/share/icons/${pname}

            runHook postInstall
        '';

        meta = with lib; {
            description = "Yet Another Monochrome Icon Set is a clean, adaptive icon theme for KDE Plasma. It automatically adjusts its color based on the background—white on dark backgrounds and black on light ones—for better visibility and a consistent look across the desktop.";
            homepage = "https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set";
            license = licenses.gpl3;
            maintainers = [myamusashi];
        };
    }
