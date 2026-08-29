{
    pkgs,
    inputs,
    config,
    ...
}: let
    sineMods = import ./sineMods.nix;
    sine-mods-json = pkgs.writeText "sine-mods.json" (builtins.toJSON sineMods);
    inherit
        (import ./sine-mods-src.nix {inherit pkgs;})
        sine-engine
        sine-profile
        sine-program
        arc20-src
        superPins-src
        newtabicon-src
        kaedriz-src
        psu-mods-src
        findbar-src
        customize-fonts-src
        fury7425-src
        tobinio-src
        ;

    zen-profile = "kxhdnjqx.zen";
in {
    imports = [
        inputs.zen-browser.homeModules.default
    ];

    xdg.desktopEntries.zen-beta = {
        name = "Zen Browser";
        exec = "/etc/profiles/per-user/myamusashi/bin/zen-beta --name zen-beta %u";
        icon = "zen-browser";
        type = "Application";
        categories = [
            "Network"
            "WebBrowser"
        ];
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

        unwrappedPackage = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta-unwrapped.overrideAttrs
        (old: {
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

            handlers = {
                mimeTypes = {
                    "text/plain" = {
                        action = 2;
                        ask = false;
                        handlers = [
                            {
                                name = "nvim-desktop";
                                path = "${inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.neovim}/bin/nvim";
                            }
                        ];
                    };
                    "text/c" = {
                        action = 2;
                        ask = false;
                        handlers = [
                            {
                                name = "nvim-desktop";
                                path = "${inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.neovim}/bin/nvim";
                            }
                        ];
                    };
                    "text/c++" = {
                        action = 2;
                        ask = false;
                        extensions = ["cpp"];
                        handlers = [
                            {
                                name = "nvim-desktop";
                                path = "${inputs.myamusashi-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.neovim}/bin/nvim";
                            }
                        ];
                    };
                    "application/pdf" = {
                        action = 2;
                        ask = false;
                        extensions = ["pdf"];
                        handlers = [
                            {
                                name = "Zathura";
                                path = "${pkgs.zathura}/bin/zathura";
                            }
                        ];
                    };
                    "image/png" = {
                        action = 2;
                        ask = false;
                        extensions = ["png"];
                        handlers = [
                            {
                                name = "lximage-qt";
                                path = "${pkgs.lxqt.lximage-qt}/bin/lximage-qt";
                            }
                        ];
                    };
                    "image/jpeg" = {
                        action = 2;
                        ask = false;
                        extensions = [
                            "jpg"
                            "jpeg"
                        ];
                        handlers = [
                            {
                                name = "lximage-qt";
                                path = "${pkgs.lxqt.lximage-qt}/bin/lximage-qt";
                            }
                        ];
                    };
                    "video/mp4" = {
                        action = 2;
                        ask = false;
                        extensions = ["mp4"];
                        handlers = [
                            {
                                name = "mpv";
                                path = "${pkgs.mpv}/bin/mpv";
                            }
                        ];
                    };
                    "video/webm" = {
                        action = 2;
                        ask = false;
                        extensions = ["webm"];
                        handlers = [
                            {
                                name = "mpv";
                                path = "${pkgs.mpv}/bin/mpv";
                            }
                        ];
                    };
                    "audio/mpeg" = {
                        action = 2;
                        ask = false;
                        extensions = ["mp3"];
                        handlers = [
                            {
                                name = "mpv";
                                path = "${pkgs.mpv}/bin/mpv";
                            }
                        ];
                    };
                };

                schemes."mailto" = {
                    action = 2;
                    ask = false;
                    handlers = [
                        {
                            name = "Thunderbird";
                            path = "${pkgs.thunderbird}/bin/thunderbird";
                        }
                    ];
                };
            };
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
}
