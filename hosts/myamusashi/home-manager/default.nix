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

  sine-mods-json = ./sine-mods.json;

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

      home = {
        stateVersion = "24.11";
        sessionPath = ["/etc/profiles/per-user/myamusashi/bin"];
      };

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

      wayland.windowManager.hyprland.enable = true;

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

        unwrappedPackage =
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta-unwrapped.overrideAttrs
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
    };
  };
}
