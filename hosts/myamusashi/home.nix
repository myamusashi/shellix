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

    newtabicon-src = pkgs.fetchFromGitHub {
        owner = "thestrike72";
        repo = "zen-browser-add-new-tab-icon-to-urlbar";
        rev = "8aef00b1e14011d389b70c26ffc1553b3a75461a";
        sha256 = "sha256-SRpNYIAAH1NHxqkylBSb54C6XVRq3SxyNs6WkC8QhRw=";
    };

    kaedriz-src = pkgs.fetchFromGitHub {
        owner = "Kaedriz";
        repo = "ZenMods";
        rev = "36ec0d0e99bff70c04764de92888e017853de3e8";
        sha256 = "sha256-uZb2XVKyEtfsllR4DBDKgRlWBvvamlPpViMCrh2FjZM=";
    };

    psu-mods-src = pkgs.fetchFromGitHub {
        owner = "psu";
        repo = "zen-mods";
        rev = "8a3505a98e37db57b51a11f19e18695f9e417bb0";
        sha256 = "sha256-LwKxT62wSb0wMdZz7Oh0LuXG/2zE8ztdJRD0SZcltLk=";
    };

    findbar-src = pkgs.fetchFromGitHub {
        owner = "RobotoSkunk";
        repo = "ff-better-findbar";
        rev = "e4781eca01ac4e84a1c3f452bd74d99eac889cec";
        sha256 = "sha256-Kgspv819xbo4jMvJ5Rg8JGKqjigfCAEnbCJYPhdzlMQ=";
    };

    customize-fonts-src = pkgs.fetchFromGitHub {
        owner = "joadr";
        repo = "zen-customize-fonts-size";
        rev = "3eb471318f70af4a66b37e38ea4bdf7275ce760e";
        sha256 = "sha256-ZmF4zgi1GKkQC6kfCUw7kBEbFyYxrgPhU6wuCi9LUxU=";
    };

    fury7425-src = pkgs.fetchFromGitHub {
        owner = "Fury7425";
        repo = "my-zen-mods";
        rev = "01e512b08661a17b0e320578f37c67abd211c4c1";
        sha256 = "sha256-lr2P0WXtVr0hbsP3SesECBni1jC1DaRHbTrs4OzsSvQ=";
    };

    tobinio-src = pkgs.fetchFromGitHub {
        owner = "ToBinio";
        repo = "zen-mods";
        rev = "ebc6056a0add63b916ca588d739f9902e6764a35";
        sha256 = "sha256-0VJnOhXUUQmYE0iCzoQ5uh8kjdaWv4AZgr2Kqwe685s=";
    };

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
        "NewTabIconUrlBar" = {
            id = "NewTabIconUrlBar";
            name = "Add New Tab Icon to URL Bar";
            description = "Adds a new tab icon to the URL bar.";
            homepage = "https://github.com/thestrike72/zen-browser-add-new-tab-icon-to-urlbar";
            version = "1.0.0";
            style = {
                chrome = "userChrome.css";
            };
            "no-updates" = true;
            enabled = true;
        };
        "AudioIndicatorEnhanced" = {
            id = "AudioIndicatorEnhanced";
            name = "Audio Indicator Enhanced";
            description = "Enhanced audio indicator with more polished style.";
            homepage = "https://github.com/Kaedriz/ZenMods/tree/main/AudioIndicatorEnhanced";
            version = "1.0.0";
            style = {
                chrome = "AudioIndicatorEnhanced.css";
            };
            preferences = "preferences.json";
            "no-updates" = true;
            enabled = true;
        };
        "BetterCtrlTab" = {
            id = "BetterCtrlTab";
            name = "Better Ctrl+Tab";
            description = "Improves the Ctrl+Tab cycle panel.";
            homepage = "https://github.com/psu/zen-mods/tree/main/better-ctrl-tab";
            version = "1.0.0";
            style = {
                chrome = "chrome.css";
            };
            preferences = "preferences.json";
            "no-updates" = true;
            enabled = true;
        };
        "ff-better-findbar" = {
            id = "ff-better-findbar";
            name = "Better Find Bar";
            description = "Improves the find bar, making it floating with theme match and customization.";
            homepage = "https://github.com/RobotoSkunk/ff-better-findbar";
            version = "1.7.0";
            style = {
                chrome = "userChrome.css";
            };
            preferences = "preferences.json";
            "no-updates" = true;
            enabled = true;
        };
        "CustomizeFontsSize" = {
            id = "CustomizeFontsSize";
            name = "Customize Fonts Size";
            description = "This Mod allows you to adjust the font size of several parts of the browser.";
            homepage = "https://github.com/joadr/zen-customize-fonts-size";
            version = "1.0.0";
            style = {
                chrome = "chrome.css";
            };
            preferences = "preferences.json";
            "no-updates" = true;
            enabled = true;
        };
        "TabPreviewEnhanced" = {
            id = "TabPreviewEnhanced";
            name = "Tab Preview Enhanced";
            description = "Enhanced tab previews.";
            homepage = "https://github.com/Kaedriz/ZenMods/tree/main/TabPreviewEnhanced";
            version = "1.0.0";
            style = {
                chrome = "TabPreviewEnhanced.css";
            };
            preferences = "preferences.json";
            "no-updates" = true;
            enabled = true;
        };
        "TabTitleFix" = {
            id = "TabTitleFix";
            name = "Tab Title Fix";
            description = "Fixes tab titles.";
            homepage = "https://github.com/psu/zen-mods/tree/main/tab-title-fix";
            version = "1.0.0";
            style = {
                chrome = "chrome.css";
            };
            preferences = "preferences.json";
            "no-updates" = true;
            enabled = true;
        };
        "TrackpadAnimation" = {
            id = "TrackpadAnimation";
            name = "Trackpad Animation";
            description = "Adds trackpad scroll animations.";
            homepage = "https://github.com/Fury7425/my-zen-mods/tree/main/trackpad-animation";
            version = "1.0.0";
            style = {
                chrome = "trackpad-animation.css";
            };
            preferences = "preferences.json";
            "no-updates" = true;
            enabled = true;
        };
        "VerticalSplitTabGroups" = {
            id = "VerticalSplitTabGroups";
            name = "Vertical Split Tab Groups";
            description = "Splits tab groups vertically.";
            homepage = "https://github.com/ToBinio/zen-mods/tree/main/vertical-split-tab-groups";
            version = "1.0.0";
            style = {
                chrome = "chrome.css";
            };
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
                "${chromeDir}/sine-mods/NewTabIconUrlBar".source = newtabicon-src;
                "${chromeDir}/sine-mods/AudioIndicatorEnhanced".source = "${kaedriz-src}/AudioIndicatorEnhanced";
                "${chromeDir}/sine-mods/BetterCtrlTab".source = "${psu-mods-src}/better-ctrl-tab";
                "${chromeDir}/sine-mods/ff-better-findbar".source = findbar-src;
                "${chromeDir}/sine-mods/CustomizeFontsSize".source = customize-fonts-src;
                "${chromeDir}/sine-mods/TabPreviewEnhanced".source = "${kaedriz-src}/TabPreviewEnhanced";
                "${chromeDir}/sine-mods/TabTitleFix".source = "${psu-mods-src}/tab-title-fix";
                "${chromeDir}/sine-mods/TrackpadAnimation".source = "${fury7425-src}/trackpad-animation";
                "${chromeDir}/sine-mods/VerticalSplitTabGroups".source = "${tobinio-src}/vertical-split-tab-groups";
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
