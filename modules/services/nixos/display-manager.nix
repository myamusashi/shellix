{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.shellix.services.nixos.display-manager;
in {
  options.shellix.services.nixos.display-manager = {
    greetd = {
      package = lib.mkPackageOption pkgs "greetd" {
        default = pkgs.greetd.greetd;
        description = "What Greetd package you want to use";
      };
      virtual-console = lib.mkOption {
        type = lib.types.int;
        default = 1;
        example = 6;
        description = "What TTY you want to occupy (this will remove the TTY you choose)";
      };
      auto-login = {
        enable = lib.mkEnableOption "Enable auto login";
        runner = lib.mkOption {
          type = lib.types.str;
          default = "Hyprland";
          example = "sway";
          description = "What command to use for running the session";
        };
        user = lib.mkOption {
          type = lib.types.str;
          default = "";
          example = "user1";
          description = "Username for auto login";
        };
      };
      greeter = lib.mkOption {
        type = lib.types.str;
        default = "tuigreet";
        example = "agreety";
        description = "Which greeter to use";
      };
      flags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = [
          "--remember-user-session"
          "--time"
        ];
        description = "Additional flags for the greeter";
      };
    };
    sddm = {
      wayland = {
        enable = lib.mkEnableOption "Enable SDDM for wayland";
        compositor = lib.mkOption {
          type = lib.types.str;
          default = "weston";
          example = "kwin";
          description = "Choose your compositor to use";
        };
      };
      theme = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "sugar-candy";
        description = "What SDDM theme you want to use";
      };
      auto-login = {
        enable = lib.mkEnableOption "Enable auto login";
        user = lib.mkOption {
          type = lib.types.str;
          default = "";
          example = "user1";
          description = "User for auto login";
        };
        session = lib.mkOption {
          type = lib.types.str;
          default = "plasma.desktop";
          example = "hyprland.desktop";
          description = "Session to auto-login to";
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.greetd.enable && cfg.sddm.enable) {
      assertions = [
        {
          assertion = false;
          message = "Cannot enable both greetd and sddm simultaneously";
        }
      ];
    })

    (lib.mkIf cfg.greetd.enable {
      services.greetd = {
        enable = true;
        inherit (cfg.greetd) package;
        vt = cfg.greetd.virtual-console;
        settings = {
          initial_session = lib.mkIf cfg.greetd.auto-login.enable {
            command = cfg.greetd.auto-login.runner;
            inherit (cfg.greetd.auto-login) user;
          };
          default_session = {
            command = let
              greeterPkg = pkgs.${cfg.greetd.greeter} or pkgs.greetd.tuigreet;
              greeterBin = "${greeterPkg}/bin/${cfg.greetd.greeter}";
              flagsStr = lib.concatStringsSep " " cfg.greetd.flags;
            in "${greeterBin} ${flagsStr}";
            user = "greeter";
          };
        };
      };
    })

    (lib.mkIf cfg.sddm.enable {
      services.displayManager.sddm = {
        enable = true;
        wayland = lib.mkIf cfg.sddm.wayland.enable {
          enable = true;
          inherit (cfg.sddm.wayland) compositor;
        };
        theme = lib.mkIf (cfg.sddm.theme != "") cfg.sddm.theme;
        settings = {
          Autologin = lib.mkIf cfg.sddm.auto-login.enable {
            Session = cfg.sddm.auto-login.session;
            User = cfg.sddm.auto-login.user;
          };
        };
      };
    })
  ];
}
