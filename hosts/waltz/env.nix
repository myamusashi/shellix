{pkgs-stable, ...}: {
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
        ];
    };
}
