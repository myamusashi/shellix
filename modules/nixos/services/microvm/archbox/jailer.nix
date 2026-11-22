{
    pkgs,
    bridgeName,
    gatewayAddress,
    subnetIpPrefix,
    subnetPrefixLength,
    primaryNameserver,
    defaultUser,
    baseImagePath,
    overlaySize,
    vmlinuxPath,
    stagedKernelPath,
    initrdFile,
}: let
    scriptsDirectory = ./scripts;
    commonShellLibrary = pkgs.writeText "fcbox-common.sh" (builtins.readFile ./scripts/common.sh);
    archReleaseSigningKey = ./keys/arch-release-signing-key.asc;
    firecrackerBinary = "${pkgs.firecracker}/bin/firecracker";
    jailerBinary = "${pkgs.firecracker}/bin/jailer";
    shellCheckFlags = [
        "-x"
        "-P"
        "${scriptsDirectory}"
    ];

    buildArchBaseScript = pkgs.writeShellApplication {
        name = "fcbox-build-arch-base";
        extraShellCheckFlags = shellCheckFlags;
        runtimeInputs = with pkgs; [
            coreutils
            curl
            e2fsprogs
            firecracker
            glibc.bin
            gnugrep
            gnupg
            gnutar
            iproute2
            jq
            util-linux
            zstd
        ];
        runtimeEnv = {
            FCBOX_COMMON_LIBRARY = commonShellLibrary;
            FCBOX_BRIDGE_NAME = bridgeName;
            FCBOX_BASE_IMAGE_PATH = toString baseImagePath;
            FCBOX_DEFAULT_USER = defaultUser;
            FCBOX_ARCH_RELEASE_SIGNING_KEY = archReleaseSigningKey;
            FCBOX_PRIMARY_NAMESERVER = primaryNameserver;
            FCBOX_FIRECRACKER_BIN = firecrackerBinary;
            FCBOX_JAILER_BIN = jailerBinary;
            FCBOX_VMLINUX_PATH = vmlinuxPath;
            FCBOX_STAGED_KERNEL_PATH = stagedKernelPath;
            FCBOX_INITRD_FILE = initrdFile;
            FCBOX_SUBNET_IP_PREFIX = subnetIpPrefix;
            FCBOX_SUBNET_PREFIX_LENGTH = subnetPrefixLength;
            FCBOX_GATEWAY_ADDRESS = gatewayAddress;
        };
        text = builtins.readFile ./scripts/build-arch-base.sh;
    };

    preStartScript = pkgs.writeShellApplication {
        name = "fcbox-prestart";
        extraShellCheckFlags = shellCheckFlags;
        runtimeInputs = with pkgs; [
            coreutils
            glibc.bin
            gnugrep
            iproute2
            jq
            util-linux
        ];
        runtimeEnv = {
            FCBOX_COMMON_LIBRARY = commonShellLibrary;
            FCBOX_BRIDGE_NAME = bridgeName;
            FCBOX_BASE_IMAGE_PATH = toString baseImagePath;
            FCBOX_FIRECRACKER_BIN = firecrackerBinary;
            FCBOX_VMLINUX_PATH = vmlinuxPath;
            FCBOX_STAGED_KERNEL_PATH = stagedKernelPath;
            FCBOX_INITRD_FILE = initrdFile;
            FCBOX_GATEWAY_ADDRESS = gatewayAddress;
            FCBOX_PRIMARY_NAMESERVER = primaryNameserver;
        };
        text = builtins.readFile ./scripts/prestart.sh;
    };

    runScript = pkgs.writeShellApplication {
        name = "fcbox-run";
        extraShellCheckFlags = shellCheckFlags;
        runtimeInputs = with pkgs; [
            coreutils
            firecracker
            gnugrep
        ];
        runtimeEnv = {
            FCBOX_COMMON_LIBRARY = commonShellLibrary;
            FCBOX_FIRECRACKER_BIN = firecrackerBinary;
            FCBOX_JAILER_BIN = jailerBinary;
        };
        text = builtins.readFile ./scripts/run.sh;
    };

    stopScript = pkgs.writeShellApplication {
        name = "fcbox-stop";
        extraShellCheckFlags = shellCheckFlags;
        runtimeInputs = with pkgs; [
            coreutils
            curl
            gnugrep
        ];
        runtimeEnv = {
            FCBOX_COMMON_LIBRARY = commonShellLibrary;
        };
        text = builtins.readFile ./scripts/stop.sh;
    };

    postStopScript = pkgs.writeShellApplication {
        name = "fcbox-poststop";
        extraShellCheckFlags = shellCheckFlags;
        runtimeInputs = with pkgs; [
            coreutils
            gnugrep
            iproute2
        ];
        runtimeEnv = {
            FCBOX_COMMON_LIBRARY = commonShellLibrary;
        };
        text = builtins.readFile ./scripts/poststop.sh;
    };

    resetScript = pkgs.writeShellApplication {
        name = "fcbox-reset";
        extraShellCheckFlags = shellCheckFlags;
        runtimeInputs = with pkgs; [
            coreutils
            e2fsprogs
            gnugrep
            systemd
        ];
        runtimeEnv = {
            FCBOX_COMMON_LIBRARY = commonShellLibrary;
            FCBOX_OVERLAY_SIZE = overlaySize;
        };
        text = builtins.readFile ./scripts/reset.sh;
    };
in {
    inherit
        commonShellLibrary
        buildArchBaseScript
        preStartScript
        runScript
        stopScript
        postStopScript
        resetScript
        ;
}
