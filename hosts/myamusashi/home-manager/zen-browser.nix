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

    # Entire Zen profile cached in RAM via tmpfs.
    # Adapted from https://wiki.archlinux.org/title/Firefox/Profile_on_RAM ("Place profile in RAM manually"):
    # Zen keeps its profile at ~/.zen/<profile> and its disk cache at ~/.cache/zen/<profile>.
    # On first run each location is moved to a static-* backup on disk and replaced with a
    # symlink into /dev/shm; later runs write RAM back to disk (.unpacked marks a populated copy).
    zen-profile-sync = pkgs.writeShellApplication {
        name = "zen-profile-sync";
        runtimeInputs = [
            pkgs.rsync
            pkgs.coreutils
            pkgs.procps
        ];
        text = ''
            set -efu
            IFS=

            if [ "$#" -ne 1 ]; then
                echo "usage: zen-profile-sync <profile>" >&2
                exit 1
            fi

            PROFILE="$1"

            sync_one() {
                base="$1"
                name="$2"
                voltag="$3"
                link="$base/$name"
                static="$base/static-$name"
                volatile="/dev/shm/zen-$voltag-$name-$(id -un)"

                mkdir -p "$base"

                if [ ! -e "$link" ] && [ ! -h "$link" ] && [ ! -e "$static" ]; then
                    mkdir -p "$link"
                fi

                if [ ! -d "$volatile" ]; then
                    mkdir -p "$volatile"
                    chmod 0700 "$volatile"
                fi

                if [ "$(readlink "$link" 2>/dev/null || true)" != "$volatile" ]; then
                    if [ -e "$static" ]; then
                        echo "error: $link is not the tmpfs copy but $static already exists; refusing to move (restore manually)" >&2
                        exit 1
                    fi
                    if pgrep -f "zen-beta|zen-bin" >/dev/null; then
                        echo "error: Zen is running; close it before the first migration of $link into RAM" >&2
                        exit 1
                    fi
                    mv "$link" "$static"
                    ln -s "$volatile" "$link"
                fi

                if [ -e "$link/.unpacked" ]; then
                    rsync -av --delete --exclude .unpacked --exclude lock --exclude .parentlock "$link"/ "$static"/
                else
                    rsync -av "$static"/ "$link"/
                    touch "$link/.unpacked"
                fi
            }

            sync_one "$HOME/.zen" "$PROFILE" "profile"
            sync_one "$HOME/.cache/zen" "$PROFILE" "cache"
        '';
    };
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
            ${builtins.readFile ./general-smooth-scrolling.pref}
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

    # Entire Zen profile on tmpfs, per https://wiki.archlinux.org/title/Firefox/Profile_on_RAM.
    # The oneshot service populates /dev/shm on login and writes back on logout/stop;
    # the timer resyncs every 30 minutes so a crash loses at most 30 minutes of profile data.
    # Close Zen before the first activation: moving a live profile corrupts it.
    systemd.user = {
        services."zen-profile-sync" = {
            Unit = {
                Description = "Sync Zen browser profile to RAM (tmpfs)";
                Documentation = ["https://wiki.archlinux.org/title/Firefox/Profile_on_RAM"];
            };
            Service = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${zen-profile-sync}/bin/zen-profile-sync ${zen-profile}";
                ExecStop = "${zen-profile-sync}/bin/zen-profile-sync ${zen-profile}";
            };
            Install = {
                WantedBy = ["default.target"];
            };
        };

        services."zen-profile-sync-resync" = {
            Unit = {
                Description = "Write back Zen browser profile from RAM to disk";
                After = ["zen-profile-sync.service"];
                BindsTo = ["zen-profile-sync.service"];
            };
            Service = {
                Type = "oneshot";
                ExecStart = "${zen-profile-sync}/bin/zen-profile-sync ${zen-profile}";
            };
        };

        timers."zen-profile-sync-resync" = {
            Unit = {
                Description = "Periodic write-back of Zen browser profile from RAM to disk";
            };
            Timer = {
                OnBootSec = "10min";
                OnUnitActiveSec = "30min";
                Unit = "zen-profile-sync-resync.service";
            };
            Install = {
                WantedBy = ["timers.target"];
            };
        };
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
