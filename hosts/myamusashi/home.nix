{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  rstd = pkgs.fetchFromGitHub {
    owner = "hypengw";
    repo = "rstd";
    rev = "7eb8b411258b4a886231b8b87f7b5a472b6712e1";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAArstdAAAAAAAAAAAAAAAA=";
  };

  asio = pkgs.fetchFromGitHub {
    owner = "chriskohlhoff";
    repo = "asio";
    rev = "asio-1-29-0";
    hash = "sha256-7Q2/9avCA/3jG7XvV5Yk9s//x8zCd3Km5m2bZHhL1yw=";
  };

  pegtl = pkgs.fetchFromGitHub {
    owner = "taocpp";
    repo = "PEGTL";
    rev = "3.2.8";
    hash = "sha256-jq/iJ3QCnGj3nE1NHVSKbr5zJqmXv2bQf1yWn0Vkud8=";
  };

  ncrequest = pkgs.fetchFromGitHub {
    owner = "hypengw";
    repo = "ncrequest";
    rev = "b919f0ad9a85dc006392ebf8802eb4c7df7584a2";
    hash = "sha256-ncrequestAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  kstore = pkgs.fetchFromGitHub {
    owner = "hypengw";
    repo = "kstore";
    rev = "d6f32d1a04be01328e1e528c0539e37b359c87e3";
    hash = "sha256-kstoreAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  qml_material = pkgs.fetchFromGitHub {
    owner = "hypengw";
    repo = "qml-material";
    rev = "872085dd6ffbb66b1e09549b12f8dc862d8619d7";
    hash = "sha256-qml_materialAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  random = pkgs.fetchFromGitHub {
    owner = "effolkronium";
    repo = "random";
    rev = "v1.5.0";
    hash = "sha256-z5yFmprOqMR38LWgqhDNknGTbVJ0sLO+nFNDgz1t8XE=";
  };

  kdsingleapplication = pkgs.fetchFromGitHub {
    owner = "KDAB";
    repo = "KDSingleApplication";
    rev = "v1.1.0";
    hash = "sha256-y3TMPyFgWCGcZnSkXfOQVt9Cf8WkOyWJKbQX8RfQMRY=";
  };
in {
  imports = [
    ../../modules/shared/Colors.nix
    ../../modules/packages/home-packages.nix
    ../../modules/programs/home-manager/default.nix
    ../../modules/services/systemd/user/default.nix
    ../../modules/services/home-manager/default.nix
  ];
  home = {
    username = "myamusashi";
    homeDirectory = "/home/myamusashi";
    stateVersion = "24.11";
    file.".config/hypr/hyprqt6engine.conf" = {
      enable = true;
      text = ''
        theme {
        	color = ${config.home.homeDirectory}/.local/share/color-schemes/Shellix.colors
        	icon_theme = la-capitaine-icon-theme
        	style = Darkly
        	font_fixed = Google Sans Flex

        	font_fixed_size = 12
        	font = Hack
        	font_size = 12
        }
      '';
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      vesktop = super.vesktop.overrideAttrs (oldAttrs: {
        preBuild = ''
          cp -r ${super.electron.dist} electron-dist
          chmod -R u+w electron-dist
        '';

        buildPhase = ''
          runHook preBuild

          pnpm build
          pnpm exec electron-builder \
            --dir \
            -c.asarUnpack="**/*.node" \
            -c.electronDist="electron-dist" \
            -c.electronVersion=${super.electron.version}

          runHook postBuild
        '';

        desktopItems = lib.optional super.stdenv.hostPlatform.isLinux (super.makeDesktopItem {
          name = "vesktop";
          desktopName = "Vesktop";
          exec = "vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
          icon = "vesktop";
          startupWMClass = "Vesktop";
          genericName = "Internet Messenger";
          keywords = [
            "discord"
            "vencord"
            "electron"
            "chat"
          ];
          categories = [
            "Network"
            "InstantMessaging"
            "Chat"
          ];
        });
      });
      qcm = super.qcm.overrideAttrs (oldAttrs: rec {
        version = "1.3.3";
        src = pkgs.fetchFromGitHub {
          owner = "hypengw";
          repo = "Qcm";
          rev = "v${version}";
          hash = "sha256-b9LKiRgD0V4zo639Rs15RmhHvqc7iYNo4/2sm1H+UhA=";
          fetchSubmodules = true;
        };

        nativeBuildInputs =
          oldAttrs.nativeBuildInputs
          ++ [
            pkgs.git
          ];

        buildInputs =
          oldAttrs.buildInputs
          ++ [
            pkgs.protobuf
            pkgs.qt6.qtgrpc
          ];

        cmakeFlags =
          (oldAttrs.cmakeFlags or [])
          ++ [
            "-DCMAKE_THREAD_LIBS_INIT=-lpthread"
            "-DCMAKE_HAVE_THREADS_LIBRARY=1"
            "-DCMAKE_USE_PTHREADS_INIT=1"
            "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"

            "-DFETCHCONTENT_SOURCE_DIR_RSTD=${rstd}"
            "-DFETCHCONTENT_SOURCE_DIR_ASIO=${asio}"
            "-DFETCHCONTENT_SOURCE_DIR_PEGTL=${pegtl}"
            "-DFETCHCONTENT_SOURCE_DIR_NCREQUEST=${ncrequest}"
            "-DFETCHCONTENT_SOURCE_DIR_KSTORE=${kstore}"
            "-DFETCHCONTENT_SOURCE_DIR_QML_MATERIAL=${qml_material}"
            "-DFETCHCONTENT_SOURCE_DIR_RANDOM=${random}"
            "-DFETCHCONTENT_SOURCE_DIR_KDSINGLEAPPLICATION=${kdsingleapplication}"
          ];

        patches = [];

        postPatch = ''
          substituteInPlace player/CMakeLists.txt \
            --replace-fail "PRIVATE cubeb::cubeb" "PRIVATE cubeb"

          substituteInPlace third_party/CMakeLists.txt \
            --replace-fail "add_library(cubeb::cubeb ALIAS cubeb)"

          substituteInPlace third_party/CMakeLists.txt \
            --replace-fail 'add_library(random ALIAS effolkronium_random)' \
                           'add_library(random ALIAS effolkronium_random)'
        '';
      });
      allegro = super.allegro.overrideAttrs (oldAttrs: {
        cmakeFlags =
          (oldAttrs.cmakeFlags or [])
          ++ [
            "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
          ];
      });
      sf-mono-liga-bin = super.stdenvNoCC.mkDerivation {
        pname = "sf-mono-liga-bin";
        version = "dev";
        src = inputs.sf-mono-liga-src;
        dontConfigure = true;
        installPhase = ''
          mkdir -p $out/share/fonts/opentype
          cp -R $src/*.otf $out/share/fonts/opentype/
        '';
      };
    })
  ];

  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    config.global = {
      hide_env_diff = true;
    };
  };

  shellix = {
    matugen.colors.enable = true;
    programs.home = {
      btop.enable = true;
      fastfetch.enable = true;
      foot.enable = true;
      htop.enable = true;
      hyprland = {
        enable = true;
        plugins = {
          enable = true;
          scrolling = {
            enable = true;
            keybind = true;
          };
          hypr-dynamic-cursors = {
            enable = true;
          };
        };
      };
      kitty.enable = true;
      lazygit.enable = true;
      mango.enable = true;
      shell.enable = true;
      yazi.enable = true;
      spicetify.enable = true;
      mpv.enable = true;
      neovim.enable = true;
      quickshell.enable = true;
      vscode.enable = true;
      matugen.enable = true;
    };

    services = {
      home-manager = {
        clipse.enable = true;
        easyeffects.enable = false;
        hypridle.enable = true;
        kdeconnect.enable = true;
      };
      systemd.user = {
        adzan.enable = true;
        nm-applet.enable = true;
        weather-widget.enable = true;
      };
    };

    packages.home = {
      enable = true;

      customPackages = [
        pkgs.git-credential-manager
        pkgs.libsixel
        pkgs.ueberzugpp
        pkgs.fd
        pkgs.p7zip
        pkgs.zellij
        pkgs.jq
        pkgs.eza
        pkgs.ripgrep
        pkgs.qtcreator
        pkgs.darkly
        pkgs.cachix
        pkgs.imagemagick
        inputs.m3shapes.packages.${pkgs.stdenv.hostPlatform.system}.m3shapes
        # pkgs.inter
        pkgs.lucide
        # (inputs.vermilion.packages.${pkgs.stdenv.hostPlatform.system}.vermilion.overrideAttrs (oldAttrs: {
        #   pnpmDeps = pkgs.pnpm_10.fetchDeps {
        #     inherit (oldAttrs) pname src;
        #     hash = "sha256-pCMwbE7eYbaOOLhWfSQtjblVctOu7nCGnUal4SID+DQ=";
        #     fetcherVersion = 2;
        #   };
        # }))
        # pkgs.asciinema
		pkgs.libnotify
        inputs.antigravity-flakes.packages.${pkgs.stdenv.hostPlatform.system}.default
        (pkgs.la-capitaine-icon-theme.overrideAttrs {dontCheckForBrokenSymlinks = true;})
        pkgs.wl-screenrec
        pkgs.qt6.qtgraphs
        pkgs.kdePackages.qtcharts
        pkgs.wl-gammactl
        pkgs.brightnessctl
        pkgs.weather-icons
        pkgs.wlr-randr
        # (pkgs.callPackage ./extra/customfetch.nix {})
        (pkgs.callPackage ./extra/google-sans-flex.nix {})
        # (pkgs.callPackage ./extra/qmlfmt.nix {})
        # (pkgs.callPackage ./extra/yet-another-monochrome-icon-set.nix {})
        # (pkgs.callPackage ./extra/fonts-audiowide.nix {})
      ];
      excludePackages = [
        "neovide"
        "rofi"
        "pinentry-curses"
        "comic-shanns-mono"
        "jetbrains-mono"
        "nix-du"
        "nix-diff"
        "vulnix"
        "deadnix"
        "nix-update"
        "onlyoffice-desktopeditors"
        "proton-qt"
        "kanagawa-icon-theme"
        "vimix-icon-theme"
        "morewaita-icon-theme"
        "whitesur-kde"
        "zed"
      ];

      fonts = {
        nerd = true;
        external = true;
      };

      nix-tools = {
        standard = true;
      };

      theming = {
        colors = true;
        apps = true;
        tools = true;
        cursors = true;
        icons = true;
        qt = true;
        gtk = true;

        defaultCursor = "Future-Cyan-Hyprcursor-theme";
        defaultCursorSize = 24;
      };

      development = {
        code_editor = true;
        containers = true;
      };

      multimedia = {
        office = true;
        apps = true;
      };

      gaming = {
        platform = true;
        utilities = true;
      };

      media = {
        editor = true;
        viewer = true;
        misc = true;
      };

      wayland = {
        core = true;
        hyprland = true;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      credential.helper = "store";

      user.name = "myamusashi";
      user.mail = "myamusashi@users.noreply.github.com";
      alias = {
        ci = "commit";
        sw = "checkout";
        s = "status";
      };
    };
    lfs.enable = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      package = with pkgs; [
        darkly
      ];
    };
  };

  gtk = {
    enable = true;

    iconTheme = {name = "WhiteSur-dark";};
    theme = {name = "WhiteSur-Dark-blue";};

    gtk3 = {
      enable = true;
      theme.name = "WhiteSur-Dark-blue";
      font = {
        name = "Hack";

        size = 11;
      };

      extraConfig = {
        "gtk-application-prefer-dark-theme" = 1;
        "gtk-enable-event-sounds" = 1;
        "gtk-enable-input-feedback-sounds" = 0;
        "gtk-xft-antialias" = 1;
        "gtk-xft-hinting" = 1;
        "gtk-icon-theme-name " = "Adwaita";
        "gtk-xft-hintstyle" = "hintslight";
        "gtk-xft-rgba" = "rgb";
      };
    };
    gtk4 = {
      enable = true;
      theme.name = "WhiteSur-Dark-blue";
      font = {
        name = "Hack";

        size = 11;
      };
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = ["Google Sans Flex"];
      monospace = ["Hack"];
      sansSerif = ["Google Sans Flex"];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-hyprland
    ];
    config = {
      common.default = "hyprland;kde";
      pantheon.default = "kde";
      gtk.default = "";
    };
  };

  targets.genericLinux.nixGL.vulkan.enable = true;
}
