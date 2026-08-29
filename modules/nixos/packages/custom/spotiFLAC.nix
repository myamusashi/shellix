{
    stdenv,
    fetchurl,
    makeWrapper,
    buildFHSEnv,
    webkitgtk_4_1,
    glib,
    gtk3,
    gdk-pixbuf,
    ...
}: let
    pname = "SpotiFLAC";
    version = "7.2.2";

    extracted = stdenv.mkDerivation {
        pname = "${pname}-extracted";
        inherit version;

        src = fetchurl {
            url = "https://github.com/spotbye/spotiflac/releases/download/v${version}/SpotiFLAC.AppImage";
            hash = "sha256-e8S4uRnMEQE31RF8jnlonI7Q2WDVRtPE6xYuSvjcD04=";
        };

        dontUnpack = true;

        nativeBuildInputs = [makeWrapper];

        installPhase = ''
            runHook preInstall

            cp $src ./SpotiFLAC.AppImage
            chmod +x SpotiFLAC.AppImage
            ./SpotiFLAC.AppImage --appimage-extract

            mkdir -p $out/{lib/${pname},share/applications,share/icons/hicolor/256x256/apps}

            cp -r squashfs-root/. $out/lib/${pname}
            rm $out/lib/${pname}/spotiflac.desktop
            rm $out/lib/${pname}/spotiflac.png
            rm -rf $out/lib/${pname}/usr/share

            install -Dm644 squashfs-root/spotiflac.desktop \
              $out/share/applications/${pname}.desktop

            install -Dm644 squashfs-root/usr/share/icons/hicolor/256x256/apps/spotiflac.png \
              $out/share/icons/hicolor/256x256/apps/${pname}.png

            runHook postInstall
        '';
    };

    fhsEnv = buildFHSEnv {
        name = pname;
        targetPkgs = _: [
            webkitgtk_4_1
            gdk-pixbuf
            glib
            gtk3
        ];
        runScript = "${extracted}/lib/${pname}/usr/bin/SpotiFLAC";
    };
in
    stdenv.mkDerivation {
        inherit pname version;

        dontUnpack = true;

        installPhase = ''
            runHook preInstall

            mkdir -p $out/{bin,share/applications,share/icons/hicolor/256x256/apps}

            ln -s ${fhsEnv}/bin/${pname} $out/bin/${pname}

            install -Dm644 ${extracted}/share/applications/${pname}.desktop \
              $out/share/applications/${pname}.desktop

            substituteInPlace $out/share/applications/${pname}.desktop \
              --replace-fail "Exec=SpotiFLAC" "Exec=$out/bin/${pname}"

            install -Dm644 ${extracted}/share/icons/hicolor/256x256/apps/${pname}.png \
              $out/share/icons/hicolor/256x256/apps/${pname}.png

            runHook postInstall
        '';

        meta = {
            description = "SpotiFLAC — Spotify with FLAC quality";
            platforms = ["x86_64-linux"];
        };
    }
