{
    lib,
    pkgs,
    mkNuApplication,
    buildArchBaseScript,
    baseImagePath,
    defaultMemoryMib,
    defaultVcpuCount,
    homeSize,
    overlaySize,
    subnetIpPrefix,
    subnetPrefixLength,
}:
mkNuApplication {
    name = "fcbox";
    src = ./scripts/cli.nu;
    runtimeInputs = with pkgs; [
        coreutils
        e2fsprogs
        openssh
        rsync
        systemd
        util-linux
        waypipe
    ];
    runtimeEnv = {
        FCBOX_BUILD_ARCH_BASE_BIN = lib.getExe buildArchBaseScript;
        FCBOX_BASE_IMAGE_PATH = toString baseImagePath;
        FCBOX_DEFAULT_MEM = toString defaultMemoryMib;
        FCBOX_DEFAULT_VCPU = toString defaultVcpuCount;
        FCBOX_HOME_SIZE = homeSize;
        FCBOX_OVERLAY_SIZE = overlaySize;
        FCBOX_SUBNET_IP_PREFIX = subnetIpPrefix;
        FCBOX_SUBNET_PREFIX_LENGTH = subnetPrefixLength;
    };
}
