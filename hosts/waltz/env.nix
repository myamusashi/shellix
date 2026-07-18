{pkgs-stable, ...}: {
    environment.systemPackages = with pkgs-stable; [
        vim
        pciutils
        fzf
        inetutils

        adb-sync
        android-tools

        forgejo-runner
        sops
        borgbackup
        cachix
        age
        alejandra
        statix
        unzip
        jq
        btop
        htop
        lazygit
        lazyjournal
        lazysql
        openssl
        home-manager
        podman-compose
        nil
        nixd
        nixdoc
        nethogs
        zellij
        nh
        starship

        podman-tui
        podman-compose
        podman

        git
        gh
        curl

        cloudflared
    ];
    environment.sessionVariables = {
        EDITOR = "vim";
    };
}
