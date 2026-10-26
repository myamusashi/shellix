final: prev: {
    material-symbols = prev.material-symbols.overrideAttrs (oldAttrs: {
        version = "4.0.0-unstable-2025-09-19";

        src = final.fetchFromGitHub {
            owner = "google";
            repo = "material-design-icons";
            rev = "bb04090f930e272697f2a1f0d7b352d92dfeee43";
            hash = "sha256-5bcEh7Oetd2JmFEPCcoweDrLGQTpcuaCU8hCjz8ls3M=";
            sparseCheckout = ["variablefont"];
        };
    });

    vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
        preBuild = ''
            cp -r ${prev.electron.dist} electron-dist
            chmod -R u+w electron-dist
        '';

        buildPhase = ''
            runHook preBuild

            pnpm build
            pnpm exec electron-builder \
              --dir \
              -c.asarUnpack="**/*.node" \
              -c.electronDist="electron-dist" \
              -c.electronVersion=${prev.electron.version}

            runHook postBuild
        '';

        desktopItems =
            prev.lib.optional prev.stdenv.hostPlatform.isLinux
            (prev.makeDesktopItem {
                name = "vesktop";
                desktopName = "Vesktop";
                exec = "vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
                icon = "vesktop";
                startupWMClass = "Vesktop";
                genericName = "Internet Messenger";
                keywords = ["discord" "vencord" "electron" "chat"];
                categories = ["Network" "InstantMessaging" "Chat"];
            });
    });
}
