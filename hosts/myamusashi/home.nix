{
    inputs,
    pkgs,
    ...
}: let
    sine-engine = pkgs.fetchzip {
        url = "https://github.com/CosmoCreeper/Sine/releases/download/v2.3.3/engine.zip";
        hash = "sha256-Gut2xrBNyrG1oBhNzlsmZpQsP4ithXOInM2Z6UUI4bo=";
    };

    sine-profile = pkgs.fetchzip {
        url = "https://github.com/sineorg/bootloader/releases/download/v0.1.4/profile.zip";
        hash = "sha256-/OkDU1Z/jC9AtMnUctU145serLOpr0D5tfCL5uo16tQ=";
    };

    sine-program = pkgs.fetchzip {
        url = "https://github.com/sineorg/bootloader/releases/download/v0.1.4/program.zip";
        hash = "sha256-6suI8iRxQr6L6uVIcs2WOWUjf6O5XipqjrHHGlKzQZc=";
        stripRoot = false;
    };

    arc20-src = pkgs.fetchFromGitHub {
        owner = "YashjitPal";
        repo = "Arc-2.0";
        rev = "70c6eb5d205cca4b4595e93a895020d3ff362dca";
        sha256 = "sha256-gXR4fiXJuwSZZ2lDWCVb8V/5BYZEmPvT9muc8vtkGko=";
    };

    superPins-src =
        pkgs.fetchFromGitHub {
            owner = "CosmoCreeper";
            repo = "Zen-Themes";
            rev = "88639a2587d076925baa33d4af3c867499da526e";
            sha256 = "sha256-Xb2C9dWArdJqNAkXFYfvrxGKglnTrqSUF8qnK5nUneE=";
        }
        + "/SuperPins";

    sine-mods-json = pkgs.writeText "sine-mods.json" (builtins.toJSON {
        "Arc-2.0" = {
            id = "Arc-2.0";
            name = "Arc 2.0";
            description = "Arc-like Zen Browser theme.";
            homepage = "https://github.com/YashjitPal/Arc-2.0";
            version = "3.3.3";
            style = {
                chrome = "userChrome.css";
                content = "userContent.css";
            };
            preferences = "preferences.json";
            "no-updates" = true;
            enabled = true;
        };
        "SuperPins" = {
            id = "SuperPins";
            name = "SuperPins";
            description = "This Zen Mod enhances pinned tabs/Essentials, by making some UI/UX changes.";
            homepage = "https://github.com/CosmoCreeper/Zen-Themes/tree/main/SuperPins";
            version = "1.7.2";
            style = {
                chrome = "chrome.css";
            };
            scripts = {
                "dist/patches.uc.mjs" = {
                    include = ["chrome://browser/content/browser.xhtml"];
                };
            };
            preferences = "preferences.json";
            origin = "store";
            supportsUnload = true;
            "no-updates" = true;
            enabled = true;
        };
    });

    zen-profile = "kxhdnjqx.zen";
in {
    imports = [
        inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        users.myamusashi = {config, ...}: {
            imports = [
                inputs.zen-browser.homeModules.default
            ];

            home.stateVersion = "24.11";

            home.sessionPath = ["/etc/profiles/per-user/myamusashi/bin"];

            xdg.desktopEntries.zen-beta = {
                name = "Zen Browser";
                exec = "/etc/profiles/per-user/myamusashi/bin/zen-beta --name zen-beta %u";
                icon = "zen-browser";
                type = "Application";
                categories = ["Network" "WebBrowser"];
                mimeType = [
                    "text/html"
                    "x-scheme-handler/http"
                    "x-scheme-handler/https"
                ];
            };

            programs.zen-browser = {
                enable = true;

                extraPrefs = ''
                    user_pref("sine.engine.auto-update", false);
                    user_pref("browser.tabs.allow_transparent_browser", true);
                    user_pref("browser.urlbar.openintab", true);
                    user_pref("zen.widget.windows.acrylic", false);
                    user_pref("browser.urlbar.trimURLs", true);
                    user_pref("browser.tabs.groups.enabled", true);
                    user_pref("arc-nogaps-compact-mod", true);
                    user_pref("arc-nogaps-mod", true);
                    user_pref("arc-pinned-extensions-mod", true);
                    user_pref("arc-remove-workspace-indicator", true);
                    user_pref("arc-workspace-style", 2);
                    user_pref("arc-tabs-no-shadow", true);
                    user_pref("arc-compact-mode-no-sidebar-bg", true);
                '';

                unwrappedPackage = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta-unwrapped
          .overrideAttrs (old: {
                    postInstall =
                        (old.postInstall or "")
                        + ''
                            for libdir in "$out/lib/zen-bin-"*; do
                              chmod -R u+w "$libdir"
                              cp ${sine-program}/config.js "$libdir/config.js"
                              mkdir -p "$libdir/defaults/pref"
                              cp ${sine-program}/defaults/pref/config-prefs.js "$libdir/defaults/pref/config-prefs.js"
                            done
                        '';
                });

                profiles.${zen-profile} = {
                    id = 0;
                    isDefault = true;
                };
            };

            home.file = let
                chromeDir = ".zen/${zen-profile}/chrome";
            in {
                "${chromeDir}/JS".source = sine-engine;
                "${chromeDir}/utils".source = sine-profile;
                "${chromeDir}/sine-mods/Arc-2.0".source = arc20-src;
                "${chromeDir}/sine-mods/SuperPins".source = superPins-src;
            };

            home.activation.seedSineMods = config.lib.dag.entryAfter ["writeBoundary"] ''
                CHROME="$HOME/.zen/${zen-profile}/chrome"
                MODS="$CHROME/sine-mods/mods.json"
                mkdir -p "$CHROME/sine-mods"
                if [ ! -e "$MODS" ]; then
                    cp ${sine-mods-json} "$MODS"
                else
                    TMP="$MODS.tmp.$$"
                    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$MODS" ${sine-mods-json} > "$TMP"
                    mv "$TMP" "$MODS"
                fi
                chmod u+w "$MODS"
            '';
        };
    };
}
