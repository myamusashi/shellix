{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware/default.nix ## Virtualization here
    ../../modules/shared/Colors.nix
    ../../modules/packages/nixos-packages.nix
    ../../modules/programs/nixos/default.nix
    ../../modules/services/nixos/default.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Asia/Jakarta";

  # Nuh uh, don't fucking changing it
  system.stateVersion = "24.11"; # Did you read the comment?

  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      insertNameservers = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
    };
    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
    extraHosts = ''
      127.0.0.1 pmo.com
    '';
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
      ];
      allowedUDPPorts = [
        22
      ];
    };
  };

  users.users.myamusashi = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "podman"
      "libvirtd"
      "qemu-libvirtd"
      "kvm"
      "video"
      "input"
      "wireshark"
    ];
  };

  services = {
    resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "true";
    };
    openssh.enable = true;
    preload.enable = true;
    xserver.xkb.layout = "us";
  };

  shellix.matugen.colors.enable = true;

  shellix.services.nixos = {
    audio.enable = true;
    earlyoom.enable = true;
    greetd.enable = true;
    plasma.enable = true;
    resolver.enable = true;
    scx.enable = true;
  };

  shellix.programs.nixos.enable = true; # If we want override the modules, just do something like programs.stuff = {doing}

  shellix.packages.nixos = {
    enable = true;

    system = true;
    network = true;
    security = true;
    android = true;

    development = {
      containers = true;
      tools = true;
    };

    wayland = {
      core = true;
    };
  };

  programs = {
    fish.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    hyprland.enable = true;
    ccache.enable = true;
    java = {
      enable = true;
      package = pkgs.jdk23;
    };
  };

  environment.sessionVariables = {
    # Theming
    GTK_THEME = "WhiteSur-Dark-blue";
    HYPRCURSOR_THEME = "Future-Cyan-Hyprcursor_Theme";
    HYPRCURSOR_SIZE = "50";
    QS_ICON_THEME = "Papirus";
    QT_QPA_PLATFORMTHEME = "qt6ct";

    # Wayland and Graphics
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    LIBVA_DRIVE_NAME = "i915";
    OZONE_PLATFORM = "wayland";
    WLR_NO_HARDWARE_CURSORS = 0;

    # Multi-GPU support
    AQ_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
    AQ_WLR_DEVICES = "/dev/dri/card1:/dev/dri/card0";
    AQ_MGPU_NO_EXPLICIT = 0;

    # Desktop Environment
    XDG_CONFIG_HOME = "/home/$USER/.config";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_MENU_PREFIX = "plasma-";

    # Application specific settings
    EDITOR = "nvim";
    MOZ_DISABLE_RDD_SANDBOX = 1;
    MOZ_ENABLE_WAYLAND = "1 firefox";
    MOZ_DRM_DEVICE = "/dev/dri/card1";
    _JAVA_AWT_WM_NONREPARENTING = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 0;
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
  };

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/chrome" = "zen.desktop";
      "text/html" = "zen.desktop";
      "application/x-extension-htm" = "zen.desktop";
      "application/x-extension-html" = "zen.desktop";
      "application/x-extension-shtml" = "zen.desktop";
      "application/xhtml+xml" = "zen.desktop";
      "application/x-extension-xhtml" = "zen.desktop";
      "application/x-extension-xht" = "zen.desktop";
      "text/plain" = "zen-browser.desktop";
      "inode/directory" = "org.kde.dolphin.desktop";
      "application/x-gnome-saved-search" = "org.kde.dolphin.desktop";
      "image/png" = "lximage-qt.desktop.in";
      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "image/jpeg" = "lximage-qt.desktop.in";
    };

    addedAssociations = {
      "x-scheme-handler/tonsite" = ["org.telegram.desktop.desktop"];
      "x-scheme-handler/http" = ["zen.desktop" "zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "x-scheme-handler/https" = ["zen.desktop" "zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "x-scheme-handler/chrome" = ["zen.desktop" "zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "text/html" = ["zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "application/x-extension-htm" = ["zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "application/x-extension-html" = ["zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "application/x-extension-shtml" = ["zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "application/xhtml+xml" = ["zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "application/x-extension-xhtml" = ["zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "application/x-extension-xht" = ["zen-browser.desktop" "zen-alpha.desktop" "zen-beta.desktop" "userapp-Zen-X27G02.desktop"];
      "text/plain" = ["neovide.desktop" "dev.zed.Zed.desktop" "zen-browser.desktop" "userapp-lvim-DQMET2.desktop" "lvim.desktop" "vim.desktop"];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["onlyoffice-desktopeditors.desktop"];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["onlyoffice-desktopeditors.desktop"];
      "image/png" = ["lximage-qt.desktop.in" "yazi.desktop"];
      "text/x-log" = ["lvim.desktop"];
      "image/svg+xml" = ["lximage-qt.desktop.in"];
      "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
      "text/x-java-source" = ["nvim.desktop"];
      "image/jpeg" = ["lximage-qt.desktop.in"];
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    enable = true;
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };
  nixpkgs.overlays = [
    (final: prev: {
      upower = prev.upower.overrideAttrs (oldAttrs: {
        doCheck = false;
      });

      vmware-workstation = prev.vmware-workstation.overrideAttrs (oldAttrs: {
        installPhase = ''
          ${oldAttrs.installPhase}

          mv $out/bin/vmware $out/bin/vmware-bin

          makeWrapper $out/bin/vmware-bin $out/bin/vmware \
            --set GTK_THEME "Adwaita-dark"

          if [ -f $out/share/applications/vmware-workstation.desktop ]; then
            substituteInPlace $out/share/applications/vmware-workstation.desktop \
              --replace "Exec=@@BINARY@@" "Exec=$out/bin/vmware"

            substituteInPlace $out/share/applications/vmware-player.desktop \
              --replace "Exec=@@BINARY@@" "Exec=$out/bin/vmware"
          fi
        '';
      });

      ## Hotfix
      python3Packages = prev.python3Packages.overrideScope (self: super: {
        tree-sitter = super.tree-sitter.overrideAttrs (oldAttrs: rec {
          version = "0.24.0";

          src = final.fetchFromGitHub {
            owner = "tree-sitter";
            repo = "py-tree-sitter";
            tag = "v${version}";
            hash = "sha256-ZDt/8suteaAjGdk71l8eej7jDkkVpVDBIZS63SA8tsU=";
            fetchSubmodules = true;
          };

          meta = {
            description = "Python bindings to the Tree-sitter parsing library";
            homepage = "https://github.com/tree-sitter/py-tree-sitter";
            changelog = "https://github.com/tree-sitter/py-tree-sitter/releases/tag/${src.tag}";
            license = final.lib.licenses.mit;
            maintainers = [final.lib.maintainers.fab];
          };
        });

        tree-sitter-rust = super.tree-sitter-rust.overrideAttrs (oldAttrs: rec {
          version = "0.23.2";

          src = final.fetchFromGitHub {
            owner = "tree-sitter";
            repo = "tree-sitter-rust";
            tag = "v${version}";
            hash = "sha256-aT+tlrEKMgWqTEq/NHh8Vj92h6i1aU6uPikDyaP2vfc=";
          };
        });

        textual = super.textual.overrideAttrs (oldAttrs: {
          meta = oldAttrs.meta // {broken = false;};
        });
      });
      ## End

      ## Fix outdated packages
      material-symbols = prev.material-symbols.overrideAttrs (oldAttrs: {
        version = "4.0.0-unstable-2025-04-11";

        src = final.fetchFromGitHub {
          owner = "google";
          repo = "material-design-icons";
          rev = "941fa95d7f6084a599a54ca71bc565f48e7c6d9e";
          hash = "sha256-5bcEh7Oetd2JmFEPCcoweDrLGQTpcuaCU8hCjz8ls3M=";
          sparseCheckout = ["variablefont"];
        };
      });

      ## Fix vmware failed buildPhase
      linuxPackages_cachyos-lto = prev.linuxPackages_cachyos-lto.extend (self: super: {
        vmware = super.vmware.overrideAttrs (oldAttrs: {
          version = "workstation-17.6.3-20250608-${self.kernel.version}";
          src = final.fetchFromGitHub {
            owner = "philipl";
            repo = "vmware-host-modules";
            rev = "e08764f84df3bd14407291e02346b7c5c54d0bf6";
            hash = "sha256-RDVKropC+VOv1uJijOGlLt6iqZI8Cm9aWlbmvZj2CSk=";
          };
          nativeBuildInputs =
            (oldAttrs.nativeBuildInputs or [])
            ++ [
              final.clang_20
              final.llvm_20
            ];
          makeFlags =
            (oldAttrs.makeFlags or [])
            ++ [
              "CC=${final.clang_20}/bin/clang"
              "HOSTCC=${final.clang_20}/bin/clang"
              "LLVM=1"
            ];
          NIX_CFLAGS_COMPILE = toString [
            "-Wno-error=implicit-function-declaration"
            "-Wno-error=implicit-int"
            "-Wno-error=deprecated-declarations"
            "-Wno-error=format-security"
            "-Wno-unused-command-line-argument"
          ];
          preBuild =
            (oldAttrs.preBuild or "")
            + ''
              export CC=${final.clang_20}/bin/clang
              export HOSTCC=${final.clang_20}/bin/clang
              export LLVM=1
              export KCFLAGS="$NIX_CFLAGS_COMPILE"

              # Ensure clang is in PATH and override any gcc references
              export PATH="${final.clang_20}/bin:$PATH"

              # Some kernel build systems check for gcc specifically, create a symlink
              mkdir -p $TMPDIR/bin
              ln -sf ${final.clang_20}/bin/clang $TMPDIR/bin/gcc
              ln -sf ${final.clang_20}/bin/clang++ $TMPDIR/bin/g++
              export PATH="$TMPDIR/bin:$PATH"
            '';
        });
      });
    })
  ];
}
