{
    lib,
    pkgs,
    commonShellLibrary,
    buildArchBaseScript,
    baseImagePath,
    defaultMemoryMib,
    defaultVcpuCount,
    homeSize,
    overlaySize,
    subnetIpPrefix,
    subnetPrefixLength,
}:
pkgs.writeShellApplication {
    name = "fcbox";
    extraShellCheckFlags = [
        "-x"
        "-P"
        "${./scripts}"
    ];
    runtimeInputs = with pkgs; [
        coreutils
        e2fsprogs
        gnugrep
        openssh
        rsync
        systemd
        util-linux
        waypipe
    ];
    runtimeEnv = {
        FCBOX_COMMON_LIBRARY = commonShellLibrary;
        FCBOX_BUILD_ARCH_BASE_BIN = lib.getExe buildArchBaseScript;
        FCBOX_BASE_IMAGE_PATH = toString baseImagePath;
        FCBOX_DEFAULT_MEM = toString defaultMemoryMib;
        FCBOX_DEFAULT_VCPU = toString defaultVcpuCount;
        FCBOX_HOME_SIZE = homeSize;
        FCBOX_OVERLAY_SIZE = overlaySize;
        FCBOX_SUBNET_IP_PREFIX = subnetIpPrefix;
        FCBOX_SUBNET_PREFIX_LENGTH = subnetPrefixLength;
    };
    text = builtins.readFile ./scripts/cli.sh;
}
