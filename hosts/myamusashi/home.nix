{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../../modules/shared/Colors.nix
    ../../modules/packages/home-packages.nix
    ../../modules/programs/home-manager/default.nix
    ../../modules/themes/default.nix
    ../../modules/services/systemd/user/default.nix
    ../../modules/services/home-manager/default.nix
  ];
  home = {
    username = "myamusashi";
    homeDirectory = "/home/myamusashi";
    stateVersion = "24.11";
  };
  programs.home-manager.enable = true;

  shellix = {
    matugen.colors.enable = true;
    # All this themes use matugen
    themes = {
      btop.enable = true;
      gtk3.enable = true;
      gtk4.enable = true;
      yazi.enable = true;
      kvantum.enable = true;
      zellij.enable = true;
      vesktop.enable = true;
    };
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
      vscode.enable = true;
    };

    services = {
      home-manager = {
        clipse.enable = true;
        easyeffects.enable = true;
        hypridle.enable = true;
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
      gnome = false;
      customPackages = [
        pkgs.git-credential-manager
        pkgs.libsixel
        pkgs.ueberzugpp
        pkgs.fd
        pkgs.p7zip
        pkgs.zellij
        pkgs.jq
        pkgs.eza
        pkgs.pcsx2
        pkgs.ripgrep
        pkgs.ripgrep-all
        pkgs.vscode-json-languageserver
        pkgs.libsForQt5.qt5.qtgraphicaleffects
        pkgs.qtcreator
        pkgs.rubik
        # inputs.caelestia-shell.packages.${pkgs.system}.default
        # inputs.caelestia-cli.packages.${pkgs.system}.default
        pkgs.inter
        (pkgs.callPackage ./extra/fonts-audiowide.nix {})
        (pkgs.callPackage ./extra/app2unit.nix {})
      ];
      excludePackages = ["neovide" "zed-editor-fhs"];

      fonts = {
        nerd = true;
        external = true;
      };

      nix-tools = {
        full = true;
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
        wallpaper = true;
        launcher = true;
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
    style = {name = "kvantum";};
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
      sansSerif = ["Montserrat"];
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
