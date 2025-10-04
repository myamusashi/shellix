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
        	font_fixed = SFProText Nerd Font
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
    })
  ];

  programs.home-manager.enable = true;

  shellix = {
    matugen.colors.enable = true;
    # All this themes use matugen
    programs.home = {
      btop.enable = true;
      fastfetch.enable = true;
      foot.enable = true;
      fuzzel.enable = false;
      htop.enable = true;
      hyprland.enable = true;
      kitty.enable = true;
      lazygit.enable = true;
      yazi.enable = true;
      mpv.enable = true;
      neovim.enable = true;
      neovide.enable = false;
      nushell.enable = false;
      walker.enable = false;
      tofi.enable = false;
      quickshell.enable = true;
      spicetify.enable = false;
      wofi.enable = false;
      winapps.enable = true;
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
        adzan.enable = true;
        shell.enable = true;
        caelestia.enable = false;
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
        pkgs.asciinema
        (pkgs.la-capitaine-icon-theme.overrideAttrs {dontCheckForBrokenSymlinks = true;})
        inputs.apple-fonts.packages.${pkgs.system}.sf-pro
        inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
        inputs.flox.packages.${pkgs.system}.default
        (pkgs.callPackage ./extra/yet-another-monochrome-icon-set.nix {})
        (pkgs.callPackage ./extra/fonts-audiowide.nix {})
        (pkgs.callPackage ./extra/app2unit.nix {})
      ];
      excludePackages = [
        "neovide"
        "zed-editor-fhs"
        "rofi"
        "comic-shanns-mono"
        "jetbrains-mono"
        "nix-du"
        "nix-diff"
        "vulnix"
        "deadnix"
        "nix-update"
        "zed-editor-fhs"
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
        screen_recorder = true;
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
    userName = "myamusashi";
    userEmail = "myamusashi@users.noreply.github.com";
    aliases = {
      ci = "commit";
      sw = "checkout";
      s = "status";
    };
    extraConfig = {
      credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
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
      serif = ["DejaVu Serif"];
      monospace = ["Hack"];
      sansSerif = ["Inter"];
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

  home.activation.discordCSS = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sf $HOME/.dots/scripts/discord_theme.css $HOME/.config/vesktop/settings/quickCss.css
  '';
}
