{
    config,
    inputs,
    lib,
    pkgs,
    ...
}: let
    cfg = config.shellix.services.microvm;
    gatewayIp = lib.head (lib.splitString "/" cfg.subnetCidr);
in {
    imports = [
        inputs.microvm.nixosModules.host
        ./archbox.nix
    ];

    options.shellix.services.microvm = {
        bridgeName = lib.mkOption {
            type = lib.types.str;
            default = "br-vm";
            description = "Linux bridge interface connecting host and Firecracker MicroVM TAP interfaces.";
        };

        subnetCidr = lib.mkOption {
            type = lib.types.str;
            default = "10.95.0.1/16";
            description = "IPv4 CIDR address assigned to the host MicroVM bridge.";
        };

        externalInterface = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "enp1s0";
            description = "Optional WAN interface used for NAT masquerading when networking.nat is active.";
        };

        nameservers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
                "1.1.1.1"
                "1.0.0.1"
            ];
            description = "Default DNS resolvers injected into managed Firecracker MicroVM guests.";
        };

        allowedBridgeTCPPorts = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            default = [];
            description = "Additional host TCP ports accessible from MicroVMs over the bridge interface.";
        };

        allowedBridgeUDPPorts = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            default = [];
            description = "Additional host UDP ports accessible from MicroVMs over the bridge interface.";
        };

        vms = lib.mkOption {
            default = {};
            description = "Declarative NixOS Firecracker MicroVMs managed via microvm.nix.";
            type = lib.types.attrsOf (
                lib.types.submodule ({name, ...}: {
                    options = {
                        vcpu = lib.mkOption {
                            type = lib.types.ints.positive;
                            default = 1;
                            description = "Number of virtual CPUs for the MicroVM.";
                        };

                        mem = lib.mkOption {
                            type = lib.types.ints.positive;
                            default = 512;
                            description = "Memory size in MiB for the MicroVM.";
                        };

                        ip = lib.mkOption {
                            type = lib.types.str;
                            example = "10.95.1.10/16";
                            description = "Static IPv4 CIDR assigned inside the guest on the bridge subnet.";
                        };

                        mac = lib.mkOption {
                            type = lib.types.str;
                            example = "02:fc:00:01:00:01";
                            description = "Guest virtio-net MAC address.";
                        };

                        tapName = lib.mkOption {
                            type = lib.types.str;
                            default = "vm-${lib.substring 0 11 name}";
                            description = "Host TAP interface name (must start with 'vm-' and be <= 15 chars).";
                        };

                        autostart = lib.mkOption {
                            type = lib.types.bool;
                            default = true;
                            description = "Whether to start this MicroVM automatically at boot.";
                        };

                        volumes = lib.mkOption {
                            type = lib.types.listOf lib.types.attrs;
                            default = [];
                            description = "Additional block volumes passed to microvm.volumes.";
                        };

                        preStart = lib.mkOption {
                            type = lib.types.lines;
                            default = "";
                            description = "Extra host preStart commands for the MicroVM runner.";
                        };

                        extraConfig = lib.mkOption {
                            type = lib.types.deferredModule;
                            default = {};
                            description = "NixOS module configuration merged into the guest MicroVM.";
                        };
                    };
                })
            );
        };
    };

    config = lib.mkMerge [
        {
            microvm.host.enable = lib.mkDefault cfg.enable;
        }
        (lib.mkIf cfg.enable {
            assertions =
                lib.mapAttrsToList (name: vm: {
                    assertion = lib.hasPrefix "vm-" vm.tapName && builtins.stringLength vm.tapName <= 15;
                    message = "shellix.services.microvm.vms.${name}.tapName ('${vm.tapName}') must start with 'vm-' and be <= 15 characters.";
                })
                cfg.vms;

            boot = {
                kernelModules = [
                    "vhost_net"
                    "tun"
                    "tap"
                ];
                kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault 1;
            };

            environment.systemPackages = with pkgs; [
                firecracker
                e2fsprogs
                iproute2
            ];

            # Keep NetworkManager from claiming the bridge or dynamic vm-* TAPs.
            networking = {
                networkmanager.unmanaged = lib.mkIf config.networking.networkmanager.enable [
                    "interface-name:${cfg.bridgeName}"
                    "interface-name:vm-*"
                ];

                nat =
                    {
                        enable = true;
                        internalInterfaces = [cfg.bridgeName];
                    }
                    // lib.optionalAttrs (cfg.externalInterface != null) {
                        inherit (cfg) externalInterface;
                    };

                firewall = {
                    filterForward = lib.mkIf config.networking.nftables.enable true;
                    interfaces.${cfg.bridgeName} = {
                        allowedTCPPorts = [53] ++ cfg.allowedBridgeTCPPorts;
                        allowedUDPPorts = [53] ++ cfg.allowedBridgeUDPPorts;
                    };
                    extraForwardRules = lib.mkIf config.networking.nftables.enable ''
                        iifname "${cfg.bridgeName}" accept
                    '';
                };
            };

            systemd.network = {
                enable = true;
                wait-online.enable = lib.mkDefault false;

                netdevs."10-${cfg.bridgeName}" = {
                    netdevConfig = {
                        Kind = "bridge";
                        Name = cfg.bridgeName;
                    };
                };

                networks = {
                    "10-${cfg.bridgeName}" = {
                        matchConfig.Name = cfg.bridgeName;
                        address = [cfg.subnetCidr];
                        networkConfig = {
                            ConfigureWithoutCarrier = true;
                            IPv4Forwarding = true;
                        };
                    };

                    "11-microvm-taps" = {
                        matchConfig.Name = "vm-*";
                        linkConfig.RequiredForOnline = "no";
                        networkConfig.Bridge = cfg.bridgeName;
                    };
                };
            };

            microvm.vms =
                lib.mapAttrs (name: vm: {
                    inherit (vm) autostart;
                    specialArgs = {inherit inputs;};
                    config = {
                        imports = [vm.extraConfig];

                        system.stateVersion = lib.mkDefault config.system.stateVersion;
                        networking = {
                            hostName = lib.mkDefault name;
                            useDHCP = lib.mkDefault false;
                            nameservers = lib.mkDefault cfg.nameservers;
                        };

                        systemd.network = {
                            enable = true;
                            networks."20-eth" = {
                                matchConfig.Type = "ether";
                                address = [vm.ip];
                                routes = [
                                    {Gateway = gatewayIp;}
                                ];
                                networkConfig.DNS = cfg.nameservers;
                            };
                        };

                        microvm = {
                            hypervisor = "firecracker";
                            storeOnDisk = true;
                            socket = "control.socket";
                            inherit (vm) vcpu mem volumes preStart;
                            interfaces = [
                                {
                                    type = "tap";
                                    id = vm.tapName;
                                    inherit (vm) mac;
                                }
                            ];
                        };
                    };
                })
                cfg.vms;
        })
    ];
}
