{
    config,
    lib,
    pkgs,
    ...
}: let
    microvmConfig = config.shellix.services.microvm;
    archboxConfig = microvmConfig.archbox;

    subnetCidrParts = lib.splitString "/" microvmConfig.subnetCidr;
    gatewayAddress = lib.head subnetCidrParts;
    subnetPrefixLength = lib.last subnetCidrParts;
    subnetOctets = lib.splitString "." gatewayAddress;
    subnetIpPrefix = "${builtins.elemAt subnetOctets 0}.${builtins.elemAt subnetOctets 1}";
    primaryNameserver = lib.head microvmConfig.nameservers;

    inherit (archboxConfig) kernelPackage;
    vmlinuxPath = "${kernelPackage.dev}/vmlinux";
    stagedKernelPath = "/var/lib/microvms/images/vmlinux-${builtins.baseNameOf kernelPackage.dev}";

    initrdArtifacts = import ./archbox/initrd.nix {
        inherit
            pkgs
            kernelPackage
            gatewayAddress
            primaryNameserver
            ;
        defaultUser = archboxConfig.user;
    };

    jailerScripts = import ./archbox/jailer.nix {
        inherit
            pkgs
            gatewayAddress
            subnetIpPrefix
            subnetPrefixLength
            primaryNameserver
            vmlinuxPath
            stagedKernelPath
            ;
        inherit (microvmConfig) bridgeName;
        inherit (archboxConfig) baseImagePath overlaySize;
        inherit (initrdArtifacts) initrdFile;
        defaultUser = archboxConfig.user;
    };

    cliPackage = import ./archbox/cli.nix {
        inherit
            lib
            pkgs
            subnetIpPrefix
            subnetPrefixLength
            ;
        inherit (jailerScripts) commonShellLibrary buildArchBaseScript;
        inherit (archboxConfig) baseImagePath homeSize overlaySize;
        defaultMemoryMib = archboxConfig.defaultMem;
        defaultVcpuCount = archboxConfig.defaultVcpu;
    };
in {
    options.shellix.services.microvm.archbox = {
        enable = lib.mkEnableOption "Enable jailer-isolated Arch Linux Firecracker MicroVMs (Distrobox replacement)";

        user = lib.mkOption {
            type = lib.types.str;
            default = "myamusashi";
            description = "Default host user provisioned in Arch Linux MicroVMs.";
        };

        defaultMem = lib.mkOption {
            type = lib.types.ints.positive;
            default = 2048;
            description = "Default memory in MiB for created Arch Linux MicroVMs.";
        };

        defaultVcpu = lib.mkOption {
            type = lib.types.ints.positive;
            default = 2;
            description = "Default vCPU count for created Arch Linux MicroVMs.";
        };

        homeSize = lib.mkOption {
            type = lib.types.str;
            default = "16G";
            description = "Sparse ext4 size for isolated per-VM \$HOME volumes.";
        };

        overlaySize = lib.mkOption {
            type = lib.types.str;
            default = "16G";
            description = "Sparse ext4 size for writable rootfs overlay volumes.";
        };

        baseImagePath = lib.mkOption {
            type = lib.types.path;
            default = "/var/lib/microvms/images/archlinux-base.ext4";
            description = "Path to the shared read-only Arch Linux ext4 base image.";
        };

        kernelPackage = lib.mkOption {
            type = lib.types.package;
            default = pkgs.linuxPackages.kernel;
            defaultText = lib.literalExpression "pkgs.linuxPackages.kernel";
            description = "Linux kernel package providing uncompressed vmlinux and virtio modules for Arch Linux MicroVMs.";
        };
    };

    config = lib.mkIf (microvmConfig.enable && archboxConfig.enable) {
        assertions = [
            {
                assertion =
                    builtins.length subnetCidrParts
                    == 2
                    && subnetPrefixLength == "16"
                    && builtins.length subnetOctets == 4;
                message = "shellix.services.microvm.subnetCidr ('${microvmConfig.subnetCidr}') must be an IPv4 /16 CIDR when archbox is enabled.";
            }
        ];

        users.groups.microvm = {};

        environment.systemPackages = with pkgs; [
            cliPackage
            jailerScripts.buildArchBaseScript
            waypipe
        ];

        systemd = {
            tmpfiles.rules = [
                "d /var/lib/microvms 0775 microvm kvm -"
                "d /var/lib/microvms/images 0755 root root -"
                "d /var/lib/microvms/archbox 2775 root microvm -"
                "f /var/lib/microvms/archbox/.lock 0660 root microvm -"
                "d /srv/jailer 0755 root root -"
                "d /srv/jailer/firecracker 0755 root root -"
            ];

            services = {
                "fcbox@" = {
                    description = "Jailer-isolated Arch Linux Firecracker MicroVM (%i)";
                    after = [
                        "network.target"
                        "systemd-networkd.service"
                    ];
                    wants = ["systemd-networkd.service"];
                    serviceConfig = {
                        # jailer --new-pid-ns clones Firecracker, writes firecracker.pid, and exits 0.
                        Type = "forking";
                        PIDFile = "/srv/jailer/firecracker/%i/root/firecracker.pid";
                        # Keep jailer's cgroup v2 leaf inside this unit's cgroup so systemd tracks and accepts the PID.
                        Delegate = "cpu memory";
                        DelegateSubgroup = "jailer_launcher";
                        ExecStartPre = "${lib.getExe jailerScripts.preStartScript} %i";
                        ExecStart = "${lib.getExe jailerScripts.runScript} %i";
                        ExecStop = "${lib.getExe jailerScripts.stopScript} %i";
                        ExecStopPost = "${lib.getExe jailerScripts.postStopScript} %i";
                        TimeoutStopSec = "30s";
                        LimitNOFILE = 1048576;
                        LimitMEMLOCK = "infinity";
                        Restart = "no";
                    };
                };

                "fcbox-reset@" = {
                    description = "Reset rootfs overlay for Arch Linux Firecracker MicroVM (%i)";
                    conflicts = ["fcbox@%i.service"];
                    after = ["fcbox@%i.service"];
                    serviceConfig = {
                        Type = "oneshot";
                        ExecStart = "${lib.getExe jailerScripts.resetScript} %i";
                    };
                };
            };
        };

        # Allow microvm/wheel group users to manage fcbox@*.service and fcbox-reset@*.service without sudo prompts.
        security.polkit.extraConfig = ''
            polkit.addRule(function(action, subject) {
                if (action.id == "org.freedesktop.systemd1.manage-units" &&
                    /^fcbox(-reset)?@[a-z0-9][a-z0-9-]{0,30}\.service$/.test(action.lookup("unit")) &&
                    (subject.isInGroup("microvm") || subject.isInGroup("wheel"))) {
                    return polkit.Result.YES;
                }
            });
        '';
    };
}
