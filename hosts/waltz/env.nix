{
    pkgs-stable,
    inputs,
    ...
}: let
    electron-flags = [
        "--enable-features=Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,VaapiIgnoreDriverChecks,VaapiVideoDecoder,VaapiVideoEncoder,AcceleratedVideoEncoder,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,UseMultiPlaneFormatForHardwareVideo,RawDraw"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
        "--disable-features=UseSkiaRenderer"
    ];

    wrapElectron = pkg: binary:
        pkgs-stable.symlinkJoin {
            name = "${pkg.pname or pkg.name}-wrapped";
            paths = [
                (pkgs-stable.writeShellScriptBin binary ''
                    export FONTCONFIG_FILE="${pkgs-stable.fontconfig.out}/etc/fonts/fonts.conf"
                    export FONTCONFIG_PATH="${pkgs-stable.fontconfig.out}/etc/fonts"
                    exec ${pkg}/bin/${binary} ${builtins.concatStringsSep " " electron-flags} "$@"
                '')
                pkg
            ];
        };
in {
    environment = {
        systemPackages = with pkgs-stable; [
            eza
            bat
            vim
            pciutils
            fzf
            inetutils
            duf
            adb-sync
            android-tools
            forgejo-runner
            sops
            cachix
            age
            alejandra
            unzip
            jq
            btop
            htop
            lazygit
            lazysql
            nil
            nh
            starship
            podman-compose
            podman
            git
            gh
            curl
            cloudflared
            (wrapElectron inputs.helium.packages.${stdenv.hostPlatform.system}.default "helium")
        ];
    };
}
