{
  lib,
  config,
  pkgs-stable,
  ...
}: let
  cfg = config.shellix.services.server.wireguard;
in {
  options.shellix.services.server.wireguard = {
    pathPrivateKeyFile = lib.mkOption {
      type = lib.types.path;
      default = "";
      example = "/etc/wireguard-keys/private";
      description = "Absolute path for private key";
    };
    externalInterfaces = lib.mkOption {
      type = lib.types.str;
      default = "enp1s0";
      example = "eth0";
      description = "Choose your network interfaces";
    };
    wireguardInterfaces = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      example = "wireguard-67";
      description = "Name your wireguard interfaces";
    };
    allowedUDPPorts = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      example = 885;
      description = "Allow UDP ports";
    };
    peers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          publicKey = lib.mkOption {
            type = lib.types.str;
            description = "Public key of the peer";
          };
          allowedIPs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "List of IPs assigned to this peer";
          };
        };
      });
      default = [];
      description = "List of allowed peers";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      nat = {
        enable = true;
        externalInterface = cfg.externalInterfaces;
        internalInterfaces = [cfg.wireguardInterfaces];
      };
      firewall.allowedUDPPorts = [cfg.allowedUDPPorts];

      wireguard.interfaces = {
        ${cfg.wireguardInterfaces} = {
          ips = ["10.100.0.1/24"];
          listenPort = cfg.allowedUDPPorts;
          postSetup = ''
            ${pkgs-stable.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${cfg.externalInterfaces} -j MASQUERADE
          '';

          # This undoes the above command
          postShutdown = ''
            ${pkgs-stable.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${cfg.externalInterfaces} -j MASQUERADE
          '';

          privateKeyFile = cfg.pathPrivateKeyFile;
          inherit (cfg) peers;
        };
      };
    };
  };
}
