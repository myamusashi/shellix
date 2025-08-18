{
  config,
  pkgs-stable,
  lib,
  ...
}: let
  VARS = import ../../modules/shared/Variable.nix;
in {
  imports = [
    ./hardware/default.nix ## Virtualization here
    ../../modules/shared/Colors.nix
    ../../modules/packages/nixos-packages.nix
    ../../modules/programs/nixos/default.nix
    ../../modules/services/nixos/default.nix
    ../../modules/services/server/default.nix
    ../../modules/services/systemd/system/default.nix
  ];

  shellix = {
    matugen.colors.enable = true;

    services = {
      server = {
        database.enable = true;
        forgejo.enable = true;
        monitoring.enable = true;
        phpmyadmin.enable = false;
        vaultwarden.enable = true;
        vsftpd.enable = true;
        nextcloud.enable = true;
        nix-serve.enable = false;
      };
      systemd.system = {
        cachix.enable = true;
        cloudflare-tunnels.enable = true;
        stirling.enable = true;
      };
      nixos = {
        earlyoom.enable = true;
        backup.enable = true;
        resolver.enable = true;
      };
    };

    programs.nixos.enable = true;

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

      customPackages = with pkgs-stable; [
        sops
        borgbackup
        cachix
        age
        alejandra
        statix
        unzip
        ntfs3g
        jq
        btop
        htop
        nix-output-monitor
        lazygit
        lazyjournal
        lazysql
        openssl
        home-manager
        podman-compose
      ];

      excludePackages = [
        "pinentry-qt"
        "pinentry-curses"
        "udisks"
        "udiskie"
        "gparted"
        "libvirt"
        "rich-cli"
        "power-profiles-daemon"
        "bluez"
        "mediainfo"
        "ouch"
        "glow"
        "hexyl"
        "antiprism"
        "wireshark"
        "nm-tray"
        "networkmanagerapplet"
        "bitwarden-desktop"
        "pass-wayland"
        "kdiff3"
      ];
    };
  };

  programs = {
    wireshark.enable = lib.mkForce false;
    xonsh.enable = lib.mkForce false;
    steam.enable = lib.mkForce false;
  };

  ## Change the default port from modules
  services = {
    openssh.enable = true;
    xserver.xkb.layout = "us";
    logind.lidSwitch = "ignore";
    forgejo.settings.server.HTTP_PORT = lib.mkForce VARS.FORGEJO_PORT;
    prometheus.port = lib.mkForce VARS.PROMETHEUS_PORT;
    prometheus.exporters.node.port = lib.mkForce VARS.PROMETHEUS-EXPORTERS_PORT;
    nginx.virtualHosts."dash.myamusashi.com".locations."/".proxyPass = lib.mkForce "http://127.0.0.1:${toString VARS.GRAFANA_PORT}";
    nginx.virtualHosts."cloud.myamusashi.com".listen = [
      {
        addr = "127.0.0.1";
        port = lib.mkForce VARS.NEXTCLOUD_PORT;
      }
    ];
    vaultwarden.config.ROCKET_PORT = lib.mkForce VARS.VAULTWARDEN_PORT;
  };

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [20 21 22];
      allowedUDPPorts = [];
    };
    extraHosts = ''
      192.168.18.14 myamusashi.com
      127.0.0.1:${toString VARS.NEXTCLOUD_PORT} cloud.myamusashi.com
      127.0.0.1:${toString VARS.PHPMYADMIN_PORT} pma.myamusashi.com
      127.0.0.1:${toString VARS.GRAFANA_PORT} dash.myamusashi.com
      127.0.0.1:${toString VARS.VAULTWARDEN_PORT} vault.myamusashi.com
    '';
  };

  sops.secrets.waltz-password.neededForUsers = true;
  users.users.waltz = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.waltz-password.path;
    description = "waltz";
    shell = pkgs-stable.fish;
    extraGroups = ["networkmanager" "wheel" "vsftpd" "docker" "podman"];
  };

  users.groups.cloudflared = {};
  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
    description = "Cloudflare Tunnel service user";
    extraGroups = ["forgejo"];
  };

  users.groups.nextcloud = {};
  users.users.nextcloud = {
    isSystemUser = true;
    group = "nextcloud";
  };

  users.groups.netdata = {};
  users.users.netdata = {
    isSystemUser = true;
    group = "netdata";
  };

  users.groups.atticd = {};
  users.users.atticd = {
    isSystemUser = true;
    group = "atticd";
  };

  users.groups.forgejo-runner = {};
  users.users.forgejo-runner = {
    isNormalUser = true;
    group = "forgejo-runner";
    extraGroups = ["forgejo" "docker" "podman"];
  };

  time.timeZone = "Asia/Jakarta";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [(import ./overlays.nix)];
  };
  nix = {
    package = pkgs-stable.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "waltz"
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
