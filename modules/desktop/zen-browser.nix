{inputs, ...}: let
    mkPatchedZenBrowser = system: let
        basePackages = inputs.nixpkgs.legacyPackages.${system};
        patchedSource = basePackages.applyPatches {
            name = "zen-browser-flake-patched";
            src = inputs.zen-browser.outPath;
            patches = [
                ../../patches/zen-browser-sine-local-mods.patch
            ];
        };
        patchedFlake = import "${patchedSource}/flake.nix";
        patchedSelf =
            inputs.zen-browser
            // {
                outPath = "${patchedSource}";
            }
            // patchedFlake.outputs {
                self = patchedSelf;
                inherit (inputs) nixpkgs home-manager;
            };
    in
        patchedSelf;
    patchedZenBrowser = mkPatchedZenBrowser "x86_64-linux";
in {
    flake.modules.homeManager.zenBrowser = {pkgs, ...}: let
        system = pkgs.stdenv.hostPlatform.system;
        neovimBinary = "${inputs.myamusashi-pkgs.packages.${system}.neovim}/bin/nvim";
        zenProfile = "kxhdnjqx.zen";
    in {
        imports = [
            patchedZenBrowser.homeModules.twilight
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
            configPath = ".zen";

            profiles.${zenProfile} = {
                id = 0;
                isDefault = true;

                sine = {
                    enable = true;
                    mods = [
                        "Arc-2.0"
                        "ad97bb70-0066-4e42-9b5f-173a5e42c6fc"
                        "378ba8b9-cd36-45f5-88df-595df5288795"
                        "2317fd93-c3ed-4f37-b55a-304c1816819e"
                        "d23733fa-983e-4680-8869-bf5b292d4fe6"
                        "7190e4e9-bead-4b40-8f57-95d852ddc941"
                        "8039de3b-72e1-41ea-83b3-5077cf0f98d1"
                        "4c2bec61-7f6c-4e5c-bdc6-c9ad1aba1827"
                    ];
                    localMods = [
                        {
                            id = "zen-matugen";
                            name = "Zen Matugen Colors";
                            source = ../../assets/color-templates/zen;
                            style = {
                                chrome = "chrome.css";
                                content = "content.css";
                            };
                            scripts = ["hot-reload.sys.mjs"];
                        }
                    ];
                };

                # sine.enable claims general.config.filename so extraPrefs cannot be used alongside it.
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
                                    path = neovimBinary;
                                }
                            ];
                        };
                        "text/c" = {
                            action = 2;
                            ask = false;
                            handlers = [
                                {
                                    name = "nvim-desktop";
                                    path = neovimBinary;
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
                                    path = neovimBinary;
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
    };
}
