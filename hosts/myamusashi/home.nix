{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
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
        	font_fixed = SFMono Nerd Font

        	font_fixed_size = 12
        	font = SF Pro Display
        	font_size = 12
        }
      '';
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      vesktop = super.vesktop.overrideAttrs (oldAttrs: {
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
      shell.enable = true;
      yazi.enable = true;
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
        pkgs.inter
        (inputs.vermilion.packages.${pkgs.system}.vermilion.overrideAttrs (oldAttrs: {
          pnpmDeps = pkgs.pnpm_10.fetchDeps {
            inherit (oldAttrs) pname src;
            hash = "sha256-nD55aAdaSfvU111rWvRm2uWQC1SFKVN+F4FaRHSVPVk=";
            fetcherVersion = 2;
          };
        }))
        pkgs.asciinema
        (pkgs.la-capitaine-icon-theme.overrideAttrs {dontCheckForBrokenSymlinks = true;})
        inputs.apple-fonts.packages.${pkgs.system}.sf-pro
        inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
        inputs.apple-fonts.packages.${pkgs.system}.sf-mono
        inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd
        pkgs.pulseaudio
        pkgs.wl-screenrec
        pkgs.sf-mono-liga-bin
        (pkgs.callPackage ./extra/yet-another-monochrome-icon-set.nix {})
        (pkgs.callPackage ./extra/fonts-audiowide.nix {})
      ];
      excludePackages = [
        "neovide"
        "rofi"
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
      credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";

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
        name = "SFMono Nerd Font";

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
        name = "SFMono Nerd Font";

        size = 11;
      };
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = ["SF Pro"];
      monospace = ["SFMono Nerd Font"];
      sansSerif = ["SF Pro"];
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

  nixGL.vulkan.enable = true;
}
