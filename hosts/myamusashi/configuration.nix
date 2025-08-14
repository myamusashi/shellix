{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./overlays.nix
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

  # If we want override the modules, just do something like *programs.stuff = {doing}*,
  # and it's same as services
  shellix.programs.nixos.enable = true;

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
    customPackage = [pkgs.git-credential-manager];
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
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "myamusashi"
      ];
      substituters = [
        "https://myamusashi.cachix.org"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://chaotic-nyx.cachix.org"
        "https://nix-community.cachix.org"
        "https://ezkea.cachix.org"
        "https://hyprland.cachix.org"
      ];

      extra-substituters = [
        # "https://cache.myamusashi.space"
      ];

      trusted-public-keys = [
        "myamusashi.cachix.org-1:ra4PbY6yqM1pSvkGqJ78CZse3WWgjk4rOXBMtjD9YrY="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];

      extra-trusted-public-keys = [
        # "cache.myamusashi.space-1:7wJ0GThM/MBLSmvDw8u8Y0XMiXAshFmX1Hz1jJ0PKWg="
      ];
    };
  };
}
