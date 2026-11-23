{
    lib,
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
    nuCheck = pkgs.writers.writeNu "fcbox-nu-check" ''
        def main [script: path, --include-path (-I): string = ""] {
            let extra_args = if ($include_path | is-empty) {
                []
            } else {
                ["--include-path" $include_path]
            }
            let diagnostics = (
                ^${lib.getExe pkgs.nushell} --no-config-file ...$extra_args --ide-check 100 $script
                | lines
                | where { |line| ($line | str trim) != "" }
                | each { |line| $line | from json }
                | where type == "diagnostic" and $it.severity in ["Error" "Warning"]
            )
            if ($diagnostics | is-not-empty) {
                for diag in $diagnostics {
                    print -e $"($script): ($diag.message)"
                }
                exit 1
            }
        }
    '';

    commonNuLibDir = pkgs.runCommandLocal "fcbox-common-nu-lib" {} ''
        mkdir -p "$out"
        cp ${./scripts/common.nu} "$out/common.nu"
        ${nuCheck} "$out/common.nu"
    '';

    mkNuApplication = {
        name,
        src,
        runtimeInputs ? [],
        runtimeEnv ? {},
    }: let
        envArgs = lib.concatLists (
            lib.mapAttrsToList (varName: value: [
                "--set"
                varName
                (toString value)
            ])
            runtimeEnv
        );
        pathArgs = lib.optionals (runtimeInputs != []) [
            "--prefix"
            "PATH"
            ":"
            (lib.makeBinPath runtimeInputs)
        ];
        libDirArgs = [
            "--set"
            "NU_LIB_DIRS"
            (toString commonNuLibDir)
        ];
    in
        pkgs.writers.writeNuBin name {
            check = "${nuCheck} -I ${commonNuLibDir}";
            makeWrapperArgs = libDirArgs ++ pathArgs ++ envArgs;
        }
        (builtins.readFile src);

    archReleaseSigningKey = ./keys/arch-release-signing-key.asc;
    firecrackerBinary = "${pkgs.firecracker}/bin/firecracker";
    jailerBinary = "${pkgs.firecracker}/bin/jailer";

    buildArchBaseScript = mkNuApplication {
        name = "fcbox-build-arch-base";
        src = ./scripts/build-arch-base.nu;
        runtimeInputs = with pkgs; [
            coreutils
            curl
            e2fsprogs
            firecracker
            glibc.bin
            gnupg
            gnutar
            iproute2
            zstd
        ];
        runtimeEnv = {
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
    };

    preStartScript = mkNuApplication {
        name = "fcbox-prestart";
        src = ./scripts/prestart.nu;
        runtimeInputs = with pkgs; [
            coreutils
            glibc.bin
            iproute2
        ];
        runtimeEnv = {
            FCBOX_BRIDGE_NAME = bridgeName;
            FCBOX_BASE_IMAGE_PATH = toString baseImagePath;
            FCBOX_FIRECRACKER_BIN = firecrackerBinary;
            FCBOX_VMLINUX_PATH = vmlinuxPath;
            FCBOX_STAGED_KERNEL_PATH = stagedKernelPath;
            FCBOX_INITRD_FILE = initrdFile;
            FCBOX_GATEWAY_ADDRESS = gatewayAddress;
            FCBOX_PRIMARY_NAMESERVER = primaryNameserver;
        };
    };

    runScript = mkNuApplication {
        name = "fcbox-run";
        src = ./scripts/run.nu;
        runtimeInputs = with pkgs; [
            coreutils
            firecracker
        ];
        runtimeEnv = {
            FCBOX_FIRECRACKER_BIN = firecrackerBinary;
            FCBOX_JAILER_BIN = jailerBinary;
        };
    };

    stopScript = mkNuApplication {
        name = "fcbox-stop";
        src = ./scripts/stop.nu;
        runtimeInputs = with pkgs; [
            coreutils
            curl
        ];
    };

    postStopScript = mkNuApplication {
        name = "fcbox-poststop";
        src = ./scripts/poststop.nu;
        runtimeInputs = with pkgs; [
            coreutils
            iproute2
        ];
    };

    resetScript = mkNuApplication {
        name = "fcbox-reset";
        src = ./scripts/reset.nu;
        runtimeInputs = with pkgs; [
            coreutils
            e2fsprogs
            systemd
        ];
        runtimeEnv = {
            FCBOX_OVERLAY_SIZE = overlaySize;
        };
    };
in {
    inherit
        commonNuLibDir
        mkNuApplication
        buildArchBaseScript
        preStartScript
        runScript
        stopScript
        postStopScript
        resetScript
        ;
}
