{inputs, ...}: {
    flake.modules.nixos.microvmHost = {
        config,
        lib,
        pkgs,
        ...
    }: let
        microvmConfig = config.shellix.microvm;
        gatewayAddress = lib.head (lib.splitString "/" microvmConfig.subnetCidr);
        ipv4OctetPattern = "(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])";
        subnetHasValidIpv4Prefix16 =
            builtins.match
            "^${ipv4OctetPattern}\\.${ipv4OctetPattern}\\.${ipv4OctetPattern}\\.${ipv4OctetPattern}/16$"
            microvmConfig.subnetCidr
            != null;
        ipv4Nameservers = builtins.filter (address: !(lib.hasInfix ":" address)) microvmConfig.nameservers;
        ipv6Nameservers = builtins.filter (address: lib.hasInfix ":" address) microvmConfig.nameservers;
        blockedIpv4Ranges = builtins.filter (range: !(lib.hasInfix ":" range)) microvmConfig.blockedForwardRanges;
        blockedIpv6Ranges = builtins.filter (range: lib.hasInfix ":" range) microvmConfig.blockedForwardRanges;

        nftablesForwardRules = lib.concatStringsSep "\n" (
            [
                "# Drop rules must precede the blanket and NAT accept rules because nftables evaluates top-to-bottom."
                ''iifname "${microvmConfig.bridgeName}" ip daddr ${gatewayAddress} accept''
            ]
            ++ lib.optional (ipv4Nameservers != []) ''iifname "${microvmConfig.bridgeName}" ip daddr { ${lib.concatStringsSep ", " ipv4Nameservers} } meta l4proto { udp, tcp } th dport 53 accept''
            ++ lib.optional (ipv6Nameservers != []) ''iifname "${microvmConfig.bridgeName}" ip6 daddr { ${lib.concatStringsSep ", " ipv6Nameservers} } meta l4proto { udp, tcp } th dport 53 accept''
            ++ lib.optional (blockedIpv4Ranges != []) ''iifname "${microvmConfig.bridgeName}" ip daddr { ${lib.concatStringsSep ", " blockedIpv4Ranges} } drop''
            ++ lib.optional (blockedIpv6Ranges != []) ''iifname "${microvmConfig.bridgeName}" ip6 daddr { ${lib.concatStringsSep ", " blockedIpv6Ranges} } drop''
            ++ [
                ''iifname "${microvmConfig.bridgeName}" accept''
            ]
        );
    in {
        key = "shellix.nixos.microvmHost";

        imports = [
            inputs.microvm.nixosModules.host
        ];

        options.shellix.microvm = {
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

            allowedBridgeTcpPorts = lib.mkOption {
                type = lib.types.listOf lib.types.port;
                default = [];
                description = "Additional host TCP ports accessible from MicroVMs over the bridge interface.";
            };

            allowedBridgeUdpPorts = lib.mkOption {
                type = lib.types.listOf lib.types.port;
                default = [];
                description = "Additional host UDP ports accessible from MicroVMs over the bridge interface.";
            };

            blockedForwardRanges = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [
                    "10.0.0.0/8"
                    "172.16.0.0/12"
                    "192.168.0.0/16"
                    "169.254.0.0/16"
                ];
                description = "Destination CIDR ranges blocked from being forwarded out of the MicroVM bridge.";
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

        config = {
            microvm.host.enable = lib.mkDefault true;

            assertions =
                [
                    {
                        assertion = subnetHasValidIpv4Prefix16;
                        message = "shellix.microvm.subnetCidr ('${microvmConfig.subnetCidr}') must be a valid IPv4 address with a /16 prefix (e.g. '10.95.0.1/16').";
                    }
                ]
                ++ lib.mapAttrsToList (name: virtualMachine: {
                    assertion = lib.hasPrefix "vm-" virtualMachine.tapName && builtins.stringLength virtualMachine.tapName <= 15;
                    message = "shellix.microvm.vms.${name}.tapName ('${virtualMachine.tapName}') must start with 'vm-' and be <= 15 characters.";
                })
                microvmConfig.vms;

            boot = {
                kernelModules = ["tun"];
                kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault 1;
            };

            environment.systemPackages = [
                pkgs.firecracker
                pkgs.e2fsprogs
                pkgs.iproute2
            ];

            # Keep NetworkManager from claiming the bridge or dynamic vm-* TAPs.
            networking = {
                networkmanager.unmanaged = lib.mkIf config.networking.networkmanager.enable [
                    "interface-name:${microvmConfig.bridgeName}"
                    "interface-name:vm-*"
                ];

                nat =
                    {
                        enable = true;
                        internalInterfaces = [microvmConfig.bridgeName];
                    }
                    // lib.optionalAttrs (microvmConfig.externalInterface != null) {
                        inherit (microvmConfig) externalInterface;
                    }
                    // lib.optionalAttrs (!config.networking.nftables.enable) {
                        # Insert the isolation chain at position 1 so drops run before NixOS NAT's blanket ACCEPT rule.
                        extraCommands = ''
                            iptables -w -t filter -N microvm-forward 2>/dev/null || iptables -w -t filter -F microvm-forward
                            iptables -w -t filter -A microvm-forward -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
                            iptables -w -t filter -A microvm-forward -d '${gatewayAddress}' -j ACCEPT
                            ${lib.concatMapStrings (address: ''
                                    iptables -w -t filter -A microvm-forward -d '${address}' -p udp --dport 53 -j ACCEPT
                                    iptables -w -t filter -A microvm-forward -d '${address}' -p tcp --dport 53 -j ACCEPT
                                '')
                                ipv4Nameservers}
                            ${lib.concatMapStrings (range: ''
                                    iptables -w -t filter -A microvm-forward -d '${range}' -j DROP
                                '')
                                blockedIpv4Ranges}
                            iptables -w -t filter -I nixos-filter-forward 1 -i '${microvmConfig.bridgeName}' -j microvm-forward
                            ${lib.optionalString (config.networking.enableIPv6 && blockedIpv6Ranges != []) ''
                                ip6tables -w -t filter -N microvm-forward 2>/dev/null || ip6tables -w -t filter -F microvm-forward
                                ip6tables -w -t filter -A microvm-forward -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
                                ${lib.concatMapStrings (address: ''
                                        ip6tables -w -t filter -A microvm-forward -d '${address}' -p udp --dport 53 -j ACCEPT
                                        ip6tables -w -t filter -A microvm-forward -d '${address}' -p tcp --dport 53 -j ACCEPT
                                    '')
                                    ipv6Nameservers}
                                ${lib.concatMapStrings (range: ''
                                        ip6tables -w -t filter -A microvm-forward -d '${range}' -j DROP
                                    '')
                                    blockedIpv6Ranges}
                                ip6tables -w -t filter -I nixos-filter-forward 1 -i '${microvmConfig.bridgeName}' -j microvm-forward
                            ''}
                        '';
                        extraStopCommands = ''
                            iptables -w -t filter -F microvm-forward 2>/dev/null || true
                            iptables -w -t filter -X microvm-forward 2>/dev/null || true
                            ${lib.optionalString config.networking.enableIPv6 ''
                                ip6tables -w -t filter -F microvm-forward 2>/dev/null || true
                                ip6tables -w -t filter -X microvm-forward 2>/dev/null || true
                            ''}
                        '';
                    };

                firewall = {
                    filterForward = lib.mkIf config.networking.nftables.enable true;
                    interfaces.${microvmConfig.bridgeName} = {
                        allowedTCPPorts = microvmConfig.allowedBridgeTcpPorts;
                        allowedUDPPorts = microvmConfig.allowedBridgeUdpPorts;
                    };
                    extraForwardRules = lib.mkIf config.networking.nftables.enable (
                        lib.mkBefore nftablesForwardRules
                    );
                };
            };

            systemd.network = {
                enable = true;
                wait-online.enable = lib.mkDefault false;

                netdevs."10-${microvmConfig.bridgeName}" = {
                    netdevConfig = {
                        Kind = "bridge";
                        Name = microvmConfig.bridgeName;
                    };
                };

                networks = {
                    "10-${microvmConfig.bridgeName}" = {
                        matchConfig.Name = microvmConfig.bridgeName;
                        address = [microvmConfig.subnetCidr];
                        networkConfig = {
                            ConfigureWithoutCarrier = true;
                            IPv4Forwarding = true;
                        };
                    };

                    "11-microvm-taps" = {
                        matchConfig.Name = "vm-*";
                        linkConfig.RequiredForOnline = "no";
                        networkConfig.Bridge = microvmConfig.bridgeName;
                        bridgeConfig.Isolated = true;
                    };
                };
            };

            microvm.vms =
                lib.mapAttrs (name: virtualMachine: {
                    inherit (virtualMachine) autostart;
                    config = {
                        imports = [virtualMachine.extraConfig];

                        system.stateVersion = lib.mkDefault config.system.stateVersion;
                        networking = {
                            hostName = lib.mkDefault name;
                            useDHCP = lib.mkDefault false;
                            nameservers = lib.mkDefault microvmConfig.nameservers;
                        };

                        systemd.network = {
                            enable = true;
                            networks."20-eth" = {
                                matchConfig.Type = "ether";
                                address = [virtualMachine.ip];
                                routes = [
                                    {Gateway = gatewayAddress;}
                                ];
                                networkConfig.DNS = microvmConfig.nameservers;
                            };
                        };

                        microvm = {
                            hypervisor = "firecracker";
                            storeOnDisk = true;
                            socket = "control.socket";
                            inherit (virtualMachine) vcpu mem volumes preStart;
                            interfaces = [
                                {
                                    type = "tap";
                                    id = virtualMachine.tapName;
                                    inherit (virtualMachine) mac;
                                }
                            ];
                        };
                    };
                })
                microvmConfig.vms;
        };
    };
}
