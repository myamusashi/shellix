{
    stdenv,
    fetchurl,
    appimageTools,
    makeWrapper,
    autoPatchelfHook,
    wrapGAppsHook3,
    lib,
    gtk3,
    glib,
    gdk-pixbuf,
    glib-networking,
    gsettings-desktop-schemas,
    libsecret,
    libepoxy,
    libGL,
    alsa-lib,
    libpulseaudio,
    mpv-unwrapped,
    wayland,
    libxkbcommon,
    libX11,
    opencore-amr,
    shine,
    speex,
    twolame,
    vo-amrwbenc,
    gst_all_1,
    xdg-user-dirs,
    jdk,
}: let
    pname = "mornye";
    version = "5.2.6";
    applicationId = "com.zarz.mornye";
    iconName = "Mornye";

    extracted = appimageTools.extract {
        inherit pname version;
        src = fetchurl {
            url = "https://github.com/mornyeapp/Mornye-Desktop/releases/download/v${version}/Mornye-v${version}-linux-x86_64.AppImage";
            hash = "sha256-PTQRQLqajPYDRprddBE3UejYoPcGLrdNQkvdYpWnZe0=";
        };
    };

    installDirectory = "$out/libexec/${pname}";
    bundledLibraryDirectory = "${installDirectory}/usr/lib/${pname}/lib";

    runtimeLoadedLibraries = [
        libGL
        libepoxy
        libsecret
        mpv-unwrapped
        alsa-lib
        libpulseaudio
        wayland
        libxkbcommon
        libX11
    ];
in
    stdenv.mkDerivation {
        inherit pname version;

        dontUnpack = true;
        dontWrapGApps = true;
        dontStrip = true;
        autoPatchelfIgnoreMissingDeps = ["libjvm.so"];

        nativeBuildInputs = [
            autoPatchelfHook
            makeWrapper
            wrapGAppsHook3
        ];

        buildInputs = [
            stdenv.cc.cc.lib
            gtk3
            glib
            gdk-pixbuf
            glib-networking
            gsettings-desktop-schemas
            libsecret
            libepoxy
            libGL
            alsa-lib
            libpulseaudio
            opencore-amr
            shine
            speex
            twolame
            vo-amrwbenc
            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
        ];

        installPhase = ''
            runHook preInstall

            mkdir -p ${installDirectory} $out/bin $out/share/icons $out/share/metainfo
            cp -r ${extracted}/. ${installDirectory}/
            chmod -R u+w ${installDirectory}

            install -Dm444 ${extracted}/${applicationId}.desktop \
                $out/share/applications/${applicationId}.desktop
            sed -i \
                -e "s|^Exec=[^ ]*|Exec=$out/bin/${pname}|" \
                -e "s|^Icon=.*|Icon=${iconName}|" \
                $out/share/applications/${applicationId}.desktop

            cp -r --no-preserve=mode ${extracted}/usr/share/icons/* $out/share/icons/
            for iconPath in $out/share/icons/hicolor/*/apps/${applicationId}.*; do
                mv "$iconPath" "$(dirname "$iconPath")/${iconName}.''${iconPath##*.}"
            done

            cp -r --no-preserve=mode ${extracted}/. ${installDirectory}/

            runHook postInstall
        '';

        preFixup = ''
            makeWrapper ${installDirectory}/usr/lib/${pname}/${pname} $out/bin/${pname} \
                "''${gappsWrapperArgs[@]}" \
                --prefix PATH : "${lib.makeBinPath [xdg-user-dirs]}" \
                --prefix LD_LIBRARY_PATH : "${bundledLibraryDirectory}:/run/opengl-driver/lib:${jdk}/lib/openjdk/lib/server:${lib.makeLibraryPath runtimeLoadedLibraries}"
        '';

        meta = {
            description = "Mornye (formerly SpotiFLAC) desktop music app";
            mainProgram = pname;
            platforms = ["x86_64-linux"];
            sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
    }
