{pkgs-stable, ...}: {
    environment = {
        systemPackages = with pkgs-stable; [
            bat
            vim
            pciutils
            fzf
            inetutils
            duf
            # adb-sync
            # android-tools
            forgejo-runner
            sops
            # cachix
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
            # podman-compose
            # podman
            git
            gh
            curl
            cloudflared
            # inputs.helium.packages.${stdenv.hostPlatform.system}.default
        ];
    };
}
