{
    inputs,
    pkgs,
    ...
}: let
    zen-wabi-src = pkgs.fetchFromGitHub {
        owner = "parazeeknova";
        repo = "zen-wabi";
        rev = "main";
        sha256 = "sha256-RmZ0WX4WzQ/TK/fbIog8p7r+kGuHe1x1heSZpBd6rI4=";
    };

    zen-profile = "default";
in {
    imports = [
        inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        users.myamusashi = {
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
                    user_pref("userChromeJS.experimental.enabled", true);
                '';

                unwrappedPackage = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta-unwrapped
          .overrideAttrs (old: {
                    postInstall =
                        (old.postInstall or "")
                        + ''
                            for libdir in "$out/lib/zen-bin-"*; do
                              chmod -R u+w "$libdir"
                              cp ${zen-wabi-src}/fx-autoconfig/program/config.js "$libdir/config.js"
                              mkdir -p "$libdir/defaults/pref"
                              cp ${zen-wabi-src}/fx-autoconfig/program/defaults/pref/config-prefs.js "$libdir/defaults/pref/config-prefs.js"
                            done
                        '';
                });

                profiles.${zen-profile} = {
                    id = 0;
                    isDefault = true;
                };
            };

            home.file = let
                chromeDir = ".config/zen/${zen-profile}/chrome";
            in {
                "${chromeDir}/JS/matugen-bridge.uc.js".source = "${zen-wabi-src}/fx-autoconfig/profile/chrome/JS/matugen-bridge.uc.js";
                "${chromeDir}/JS/Matugen/MatugenParent.sys.mjs".source = "${zen-wabi-src}/fx-autoconfig/profile/chrome/JS/Matugen/MatugenParent.sys.mjs";
                "${chromeDir}/JS/Matugen/MatugenChild.sys.mjs".source = "${zen-wabi-src}/fx-autoconfig/profile/chrome/JS/Matugen/MatugenChild.sys.mjs";
                "${chromeDir}/utils/boot.sys.mjs".source = "${zen-wabi-src}/fx-autoconfig/profile/chrome/utils/boot.sys.mjs";
                "${chromeDir}/utils/chrome.manifest".source = "${zen-wabi-src}/fx-autoconfig/profile/chrome/utils/chrome.manifest";
                "${chromeDir}/utils/fs.sys.mjs".source = "${zen-wabi-src}/fx-autoconfig/profile/chrome/utils/fs.sys.mjs";
                "${chromeDir}/utils/module_loader.mjs".source = "${zen-wabi-src}/fx-autoconfig/profile/chrome/utils/module_loader.mjs";
                "${chromeDir}/utils/uc_api.sys.mjs".source = "${zen-wabi-src}/fx-autoconfig/profile/chrome/utils/uc_api.sys.mjs";
                "${chromeDir}/utils/utils.sys.mjs".source = "${zen-wabi-src}/fx-autoconfig/profile/chrome/utils/utils.sys.mjs";
                ".config/zen/userChrome.css.template".source = "${zen-wabi-src}/userChrome.css.template";
                ".config/zen/userContent.css.template".source = "${zen-wabi-src}/userContent.css.template";
                ".config/zen/userContent.github.template".source = "${zen-wabi-src}/userContent.github.template";
                ".config/zen/user.js.template".source = "${zen-wabi-src}/user.js.template";
            };
        };
    };
}
