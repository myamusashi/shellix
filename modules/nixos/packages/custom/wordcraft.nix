{
    stdenv,
    fetchurl,
    appimageTools,
    makeWrapper,
    autoPatchelfHook,
    wrapGAppsHook4,
    lib,
    gtk4,
    glib,
    gdk-pixbuf,
    graphene,
    glib-networking,
    gsettings-desktop-schemas,
    libpulseaudio,
    alsa-lib,
    pipewire,
    vulkan-loader,
    libGL,
    libva,
    libxkbcommon,
    wayland,
    libXrandr,
    libXcursor,
    libXi,
    libX11,
    libxinerama,
    libxxf86vm,
    liberation_ttf,
    carlito,
    caladea,
}: let
    pname = "wordcraft";
    version = "0.6.1";

    appImage = fetchurl {
        url = "https://github.com/storytold/${pname}/releases/download/v${version}/${pname}-${version}-linux-x86_64.AppImage";
        sha256 = "sha256-Nu04RMTlg5HPE0HRM79rVptSIfjnB+Xicds8ON9tw8M=";
    };

    extracted = appimageTools.extract {
        inherit pname version;
        src = appImage;
    };

    collegeFonts = [
        liberation_ttf
        carlito
        caladea
    ];

    dlopenLibraries = [
        vulkan-loader
        libGL
        libva
        libpulseaudio
        alsa-lib
        pipewire
        wayland
        libXrandr
        libXcursor
        libXi
        libX11
        libxkbcommon
    ];

    desktopFile = "ai.storyteller.wordcraft.desktop";
in
    stdenv.mkDerivation {
        inherit pname version;

        nativeBuildInputs = [
            wrapGAppsHook4
            makeWrapper
            autoPatchelfHook
        ];

        buildInputs = [
            stdenv.cc.cc.lib
            glib
            gdk-pixbuf
            graphene
            gtk4
            glib-networking
            gsettings-desktop-schemas
            libpulseaudio
            alsa-lib
            pipewire
            vulkan-loader
            libGL
            libxkbcommon
            wayland
            libXrandr
            libXcursor
            libXi
            libX11
            libxinerama
            libxxf86vm
        ];

        unpackPhase = ''
            cp -r ${extracted} extracted
            chmod -R u+w extracted
        '';

        dontDropIconThemeCache = true;

        installPhase = ''
            runHook preInstall

            mkdir -p $out/libexec/${pname} $out/bin
            cp -r extracted/* $out/libexec/${pname}/

            makeWrapper $out/libexec/${pname}/AppRun $out/bin/${pname} \
              --unset DISPLAY \
              --prefix XDG_DATA_DIRS : "${lib.makeSearchPath "share" collegeFonts}" \
              --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${lib.makeLibraryPath dlopenLibraries}" \
              --set-default LIBVA_DRIVERS_PATH "/run/opengl-driver/lib/dri"

            install -Dm444 extracted/${desktopFile} $out/share/applications/${desktopFile}
            substituteInPlace $out/share/applications/${desktopFile} \
                --replace-fail "Exec=${pname}" "Exec=$out/bin/${pname}"

            mkdir -p $out/share/icons $out/share/metainfo $out/share/mime/packages
            cp -r extracted/usr/share/icons/* $out/share/icons/ 2>/dev/null || true
            cp extracted/usr/share/metainfo/*.metainfo.xml $out/share/metainfo/ 2>/dev/null || true
            cp extracted/usr/share/mime/packages/*.xml $out/share/mime/packages/ 2>/dev/null || true

            runHook postInstall
        '';

        meta = {
            description = "FilmCraft: An open-source, nonlinear video editor written in pure Rust";
            homepage = "https://github.com/storytold/filmcraft";
            license = lib.licenses.mit;
            maintainers = [];
            platforms = ["x86_64-linux" "aarch64-linux"];
            sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
    }
