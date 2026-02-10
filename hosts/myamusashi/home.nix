{
  pkgs,
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
        	font_fixed = Google Sans Flex

        	font_fixed_size = 12
        	font = Hack
        	font_size = 12
        }
      '';
    };
  };

  programs = {
    home-manager.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;

      config.global = {
        hide_env_diff = true;
      };
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
	  neovide.enable = true;
      quickshell.enable = false;
      vscode.enable = true;
      matugen.enable = true;
    };

    services = {
      home-manager = {
        clipse.enable = true;
        easyeffects.enable = true;
        hypridle.enable = true;
        kdeconnect.enable = true;
      };
      systemd.user = {
        adzan.enable = false;
        nm-applet.enable = true;
        weather-widget.enable = false;
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
        pkgs.gapless
        pkgs.ripgrep
        pkgs.qtcreator
        pkgs.darkly
        pkgs.imagemagick
        pkgs.lucide
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
        (pkgs.callPackage ./extra/google-sans-flex.nix {})
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
    };
  };

  targets.genericLinux.nixGL.vulkan.enable = true;
}
