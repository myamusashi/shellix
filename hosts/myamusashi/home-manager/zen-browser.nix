{
    pkgs,
    inputs,
    ...
}: let
    zen-profile = "kxhdnjqx.zen";

    # Zen profile cached in RAM via tmpfs.
    # Adapted from https://wiki.archlinux.org/title/Firefox/Profile_on_RAM ("Place profile in RAM manually"):
    # Zen keeps its profile at ~/.zen/<profile>.
    # On first run the location is moved to a static-* backup on disk and replaced with a
    # symlink into /dev/shm; later runs write RAM back to disk (.unpacked marks a populated copy).
    # Only the profile lives in tmpfs. The disk cache (~/.cache/zen/<profile>/cache2, ~1.1G) stays
    # on disk: Firefox re-downloads it on demand, so pinning it in RAM bought nothing and cost
    # 1.1G of permanently-resident shmem plus a 1.1G rsync on every logout.
    # zen-profile-sync = pkgs.writeShellApplication {
    #     name = "zen-profile-sync";
    #     runtimeInputs = [
    #         pkgs.rsync
    #         pkgs.coreutils
    #         pkgs.procps
    #     ];
    #     text = ''
    #         set -efu
    #         IFS=
    #
    #         if [ "$#" -ne 1 ]; then
    #             echo "usage: zen-profile-sync <profile>" >&2
    #             exit 1
    #         fi
    #
    #         PROFILE="$1"
    #
    #         sync_one() {
    #             base="$1"
    #             name="$2"
    #             link="$base/$name"
    #             static="$base/static-$name"
    #             volatile="/dev/shm/zen-profile-$name-$(id -un)"
    #
    #             mkdir -p "$base"
    #
    #             if [ ! -e "$link" ] && [ ! -h "$link" ] && [ ! -e "$static" ]; then
    #                 mkdir -p "$link"
    #             fi
    #
    #             if [ ! -d "$volatile" ]; then
    #                 mkdir -p "$volatile"
    #                 chmod 0700 "$volatile"
    #             fi
    #
    #             if [ "$(readlink "$link" 2>/dev/null || true)" != "$volatile" ]; then
    #                 if [ -e "$static" ]; then
    #                     echo "error: $link is not the tmpfs copy but $static already exists; refusing to move (restore manually)" >&2
    #                     exit 1
    #                 fi
    #                 if pgrep -f "zen-beta|zen-twilight|zen-bin" >/dev/null; then
    #                     echo "error: Zen is running; close it before the first migration of $link into RAM" >&2
    #                     exit 1
    #                 fi
    #                 mv "$link" "$static"
    #                 ln -s "$volatile" "$link"
    #             fi
    #
    #             if [ -e "$link/.unpacked" ]; then
    #                 rsync -av --delete --exclude .unpacked --exclude lock --exclude .parentlock "$link"/ "$static"/
    #             else
    #                 rsync -av "$static"/ "$link"/
    #                 touch "$link/.unpacked"
    #             fi
    #         }
    #
    #         sync_one "$HOME/.zen" "$PROFILE"
    #     '';
    # };
in {
    imports = [
        inputs.zen-browser.homeModules.twilight
    ];

    xdg.desktopEntries.zen-twilight = {
        name = "Zen Browser";
        exec = "/etc/profiles/per-user/myamusashi/bin/zen-twilight --name zen-twilight %u";
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

        # HM defaults to ~/.config/zen, but the live profile runs from
        # ~/.zen/<profile> (tmpfs-backed, see zen-profile-sync below).
        # Point configPath there so the flake's Sine engine files and
        # activation fragments land where Zen actually reads them.
        configPath = ".zen";

        profiles.${zen-profile} = {
            id = 0;
            isDefault = true;

            sine.enable = true;
            # Resolved from the Sine store, falling back to the Zen theme store
            # (theme UUIDs). Previous manual GitHub pins mapped to equivalents:
            sine.mods = [
                "Arc-2.0" # Arc-2.0 (Sine store)
                "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins (Sine store)
                "378ba8b9-cd36-45f5-88df-595df5288795" # NewTabIconUrlBar (theme-store fallback)
                "2317fd93-c3ed-4f37-b55a-304c1816819e" # AudioIndicatorEnhanced (theme-store fallback)
                "d23733fa-983e-4680-8869-bf5b292d4fe6" # CustomizeFontsSize (theme-store fallback)
                "7190e4e9-bead-4b40-8f57-95d852ddc941" # TabTitleFix (theme-store fallback)
                "8039de3b-72e1-41ea-83b3-5077cf0f98d1" # TrackpadAnimation (theme-store fallback, same author)
                "4c2bec61-7f6c-4e5c-bdc6-c9ad1aba1827" # VerticalSplitTabGroups (theme-store fallback)
            ];

            # Replaces the old extraPrefs block: sine.enable forbids extraPrefs
            # (both claim general.config.filename; the bootloader wins), and the
            # flake force-sets sine.engine.auto-update = false itself.
            settings = {
                "general.smoothScroll.lines.durationMaxMS" = 125;
                "general.smoothScroll.lines.durationMinMS" = 125;
                "general.smoothScroll.mouseWheel.durationMaxMS" = 200;
                "general.smoothScroll.mouseWheel.durationMinMS" = 100;
                "general.smoothScroll.msdPhysics.enabled" = true;
                "general.smoothScroll.other.durationMaxMS" = 125;
                "general.smoothScroll.other.durationMinMS" = 125;
                "general.smoothScroll.pages.durationMaxMS" = 125;
                "general.smoothScroll.pages.durationMinMS" = 125;
                "browser.tabs.allow_transparent_browser" = true;
                "browser.urlbar.openintab" = true;
                "zen.widget.windows.acrylic" = false;
                "browser.urlbar.trimURLs" = true;
                "browser.tabs.groups.enabled" = true;
                "arc-nogaps-compact-mod" = true;
                "arc-nogaps-mod" = true;
                "arc-pinned-extensions-mod" = true;
                "arc-remove-workspace-indicator" = true;
                "arc-workspace-style" = 2;
                "arc-tabs-no-shadow" = true;
                "arc-compact-mode-no-sidebar-bg" = true;
            };

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

    # Entire Zen profile on tmpfs, per https://wiki.archlinux.org/title/Firefox/Profile_on_RAM.
    # The oneshot service populates /dev/shm on login and writes back on logout/stop;
    # the timer resyncs every 30 minutes so a crash loses at most 30 minutes of profile data.
    # Close Zen before the first activation: moving a live profile corrupts it.
    # systemd.user = {
    #     services."zen-profile-sync" = {
    #         Unit = {
    #             Description = "Sync Zen browser profile to RAM (tmpfs)";
    #             Documentation = ["https://wiki.archlinux.org/title/Firefox/Profile_on_RAM"];
    #         };
    #         Service = {
    #             Type = "oneshot";
    #             RemainAfterExit = true;
    #             ExecStart = "${zen-profile-sync}/bin/zen-profile-sync ${zen-profile}";
    #             ExecStop = "${zen-profile-sync}/bin/zen-profile-sync ${zen-profile}";
    #         };
    #         Install = {
    #             WantedBy = ["default.target"];
    #         };
    #     };
    #
    #     services."zen-profile-sync-resync" = {
    #         Unit = {
    #             Description = "Write back Zen browser profile from RAM to disk";
    #             After = ["zen-profile-sync.service"];
    #             BindsTo = ["zen-profile-sync.service"];
    #         };
    #         Service = {
    #             Type = "oneshot";
    #             ExecStart = "${zen-profile-sync}/bin/zen-profile-sync ${zen-profile}";
    #         };
    #     };
    #
    #     timers."zen-profile-sync-resync" = {
    #         Unit = {
    #             Description = "Periodic write-back of Zen browser profile from RAM to disk";
    #         };
    #         Timer = {
    #             OnBootSec = "10min";
    #             OnUnitActiveSec = "30min";
    #             Unit = "zen-profile-sync-resync.service";
    #         };
    #         Install = {
    #             WantedBy = ["timers.target"];
    #         };
    #     };
    # };
}
