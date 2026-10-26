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

    appImage = fetchurl {
        url = "https://github.com/mornyeapp/Mornye-Desktop/releases/download/v${version}/Mornye-v${version}-linux-x86_64.AppImage";
        hash = "sha256-PTQRQLqajPYDRprddBE3UejYoPcGLrdNQkvdYpWnZe0=";
    };

    extracted = appimageTools.extract {
        inherit pname version;
        src = appImage;
    };

    dlopenLibraries = [
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

    bundledLibraryDirectory = "$out/libexec/${pname}/usr/lib/${pname}/lib";
in
    stdenv.mkDerivation {
        inherit pname version;

        nativeBuildInputs = [
            wrapGAppsHook3
            makeWrapper
            autoPatchelfHook
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

        unpackPhase = ''
            cp -r ${extracted} extracted
            chmod -R u+w extracted
        '';

        dontWrapGApps = true;
        dontStrip = true;
        autoPatchelfIgnoreMissingDeps = ["libjvm.so"];

        installPhase = ''
            runHook preInstall

            mkdir -p $out/libexec/${pname} $out/bin
            cp -r extracted/. $out/libexec/${pname}/

            install -Dm444 extracted/${applicationId}.desktop \
              $out/share/applications/${applicationId}.desktop
            sed -i "s|^Exec=[^ ]*|Exec=$out/bin/${pname}|" \
              $out/share/applications/${applicationId}.desktop

            mkdir -p $out/share/icons $out/share/metainfo
            cp -r extracted/usr/share/icons/* $out/share/icons/
            cp extracted/usr/share/metainfo/*.metainfo.xml $out/share/metainfo/

            runHook postInstall
        '';

        preFixup = ''
            makeWrapper $out/libexec/${pname}/usr/lib/${pname}/${pname} $out/bin/${pname} \
              "''${gappsWrapperArgs[@]}" \
              --prefix PATH : "${lib.makeBinPath [xdg-user-dirs]}" \
              --prefix LD_LIBRARY_PATH : "${bundledLibraryDirectory}:/run/opengl-driver/lib:${jdk}/lib/openjdk/lib/server:${lib.makeLibraryPath dlopenLibraries}"
        '';

        meta = {
            description = "Mornye (formerly SpotiFLAC) desktop music app";
            mainProgram = pname;
            platforms = ["x86_64-linux"];
            sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
    }
