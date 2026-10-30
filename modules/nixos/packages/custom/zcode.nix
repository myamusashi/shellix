{
    lib,
    appimageTools,
    fetchurl,
}: let
    pname = "zcode";
    version = "3.16.3";

    arch = "x64";

    src = fetchurl {
        url = "https://cdn-zcode.z.ai/zcode/electron/releases/${version}/linux-${arch}/ZCode-${version}-linux-${arch}.AppImage";
        hash = "sha512-GH9hXVJFQCHma9EIX1GiiWFYwbzdZXROqQkDc6EWtq59v0jfYOP5kPvyuLIANKriuoRorCuJTrSmricoHO+Wgg==";
    };

    appimageContents = appimageTools.extract {
        inherit pname version src;
    };
in
    appimageTools.wrapAppImage {
        inherit pname version;
        src = appimageContents;

        extraInstallCommands = ''
            install -Dm444 ${appimageContents}/${pname}.desktop -t $out/share/applications
            cp -r ${appimageContents}/usr/share/icons $out/share
            # Point the desktop entry at the wrapped binary and keep upstream's
            # --no-sandbox launch (matches the shipped AppRun invocation).
            substituteInPlace $out/share/applications/${pname}.desktop \
              --replace-fail 'Exec=AppRun --no-sandbox %U' "Exec=$out/bin/${pname} --no-sandbox %U"
        '';

        meta = with lib; {
            description = "Agentic, multi-agent vibe-coding desktop app by Z.AI (official harness for GLM-5)";
            longDescription = ''
                ZCode is Z.AI's next-generation "vibe coding" desktop app for complex,
                multi-agent development goals. It is the official harness for the GLM
                family of coding models and supports running and controlling multiple
                agents from anywhere.
            '';
            homepage = "https://zcode.z.ai";
            downloadPage = "https://zcode.z.ai/en";
            changelog = "https://zcode.z.ai/en/changelog";
            license = licenses.unfree;
            sourceProvenance = [sourceTypes.binaryNativeCode];
            platforms = ["x86_64-linux"];
            maintainers = with lib.maintainers; [perryh];
            mainProgram = pname;
        };
    }
