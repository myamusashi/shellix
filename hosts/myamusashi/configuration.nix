{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./hardware/default.nix
    ../../modules/shared/Colors.nix
    ../../modules/packages/nixos-packages.nix
    ../../modules/programs/nixos/default.nix
    ../../modules/services/nixos/default.nix
  ];
  sops.age.keyFile = lib.mkForce "/home/myamusashi/.config/sops/age/keys1.txt";
  sops.secrets.weatherapi.owner = "myamusashi";
  sops.secrets.latitude.owner = "myamusashi";
  sops.secrets.longitude.owner = "myamusashi";

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Asia/Jakarta";

  # Nuh uh, don't fucking changing it
  system.stateVersion = "24.11"; # Did you read the comment?

  networking = {
    hostName = "nixos";
    defaultGateway = {
      address = "192.168.18.1";
      interface = "enp0s31f6";
    };
    dhcpcd.enable = false;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      insertNameservers = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
        "94.140.14.14" # adGuard
        "94.140.15.15"
      ];
    };
    domain = "home.myamusashi.dev";
    search = ["home.myamusashi.dev"];
    interfaces = {
      enp0s31f6.ipv4.addresses = [
        {
          address = "192.168.18.2";
          prefixLength = 28;
        }
      ];
      myamusashi.ipv4.addresses = [
        {
          address = "10.10.10.1";
          prefixLength = 24;
        }
      ];
    };
    vlans = {
      myamusashi = {
        id = 2;
        interface = "enp0s31f6";
      };
    };
    nameservers = [
      "192.168.18.4"
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "94.140.14.14"
      "94.140.15.15"
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
        51820
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
    wg-quick.interfaces = {
      wg0 = {
        mtu = 1420;
        address = lib.mkDefault ["10.0.0.3/32"];
        listenPort = 51820;
        dns = ["10.0.0.1" "1.1.1.1"];
        privateKeyFile = "/etc/wireguard-keys/private.key";
        peers = [
          {
            publicKey = "IzirsljupeFXLusg6CooDzjSfc/xGVehBuJetADkaEU=";
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "192.168.18.14:51820";
          }
        ];
      };
    };
  };

  sops.secrets.myamusashi-password.neededForUsers = true;
  sops.secrets.myamusashi-password.owner = config.users.users.myamusashi.name;
  users.users.myamusashi = {
    isNormalUser = true;
    # hashedPasswordFile = config.sops.secrets.myamusashi-password.path;
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
    cloudflare-warp.enable = true;
    openssh.enable = true;
    preload.enable = true;
    xserver.xkb.layout = "us";
  };

  shellix = {
    matugen.colors.enable = true;

    services.nixos = {
      audio.enable = true;
      backup.myamusashi.enable = true;
      earlyoom.enable = true;
      plasma.enable = true;
      resolver.enable = true;
      scx.enable = true;
      display-manager = {
        sddm = {
          enable = true;
          wayland = {
            enable = true;
            compositor = "weston";
          };
          theme = "sddm-astronaut-theme";
          auto-login = {
            enable = true;
            user = "myamusashi";
            session = "hyprland.desktop";
          };
        };
      };
    };

    programs.nixos = {
      fish.enable = true;
      starship.enable = true;
      steam.enable = true;
      virt-manager.enable = false;
      wireshark.enable = false;
      xonsh.enable = false;
    };

    packages.nixos = {
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

      winapps = true;

      customPackages = with pkgs; [
        sddm-astronaut
        kdePackages.qtmultimedia
        git-credential-manager
        sops
        lxqt.pcmanfm-qt
        lxqt.pavucontrol-qt
        gvfs
        iptables
      ];
      excludePackages = [
        "libvirt"
      ];
    };
  };

  programs = {
    fish.enable = true;
    dconf.enable = true;
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

  services.gvfs.enable = true;

  environment.sessionVariables = {
    # Theming
    GTK_THEME = "WhiteSur-Dark-blue";
    HYPRCURSOR_THEME = "Future-Cyan-Hyprcursor_Theme";
    HYPRCURSOR_SIZE = "50";
    QS_ICON_THEME = "Papirus";
    QT_QPA_PLATFORMTHEME = "qt6ct";

    # Wayland and Graphics
    GTK_USE_PORTAL = 0;
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
    MOZ_ENABLE_WAYLAND = "1 zen";
    MOZ_DRM_DEVICE = "/dev/dri/card1";
    _JAVA_AWT_WM_NONREPARENTING = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 0;
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
  };

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      "text/plain" = "zen-browser.desktop";
      "inode/directory" = "pcmanfm-qt.desktop";
      "application/x-gnome-saved-search" = "pcmanfm-qt.desktop";
      "image/png" = "lximage-qt.desktop.in";
      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "image/jpeg" = "lximage-qt.desktop.in";
    };

    addedAssociations = {
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["draw.desktop"];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["impress.desktop"];
      "image/png" = ["lximage-qt.desktop.in" "yazi.desktop"];
      "text/x-log" = ["lvim.desktop"];
      "image/svg+xml" = ["lximage-qt.desktop.in"];
      "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
      "text/x-java-source" = ["nvim.desktop"];
      "image/jpeg" = ["lximage-qt.desktop.in"];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [(import ./overlays.nix)];
  };
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
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
        "https://cache.flox.dev"
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
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      ];

      extra-trusted-public-keys = [
        # "cache.myamusashi.space-1:7wJ0GThM/MBLSmvDw8u8Y0XMiXAshFmX1Hz1jJ0PKWg="
      ];
    };
  };
}
