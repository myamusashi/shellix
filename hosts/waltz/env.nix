{
    config,
    lib,
    pkgs-stable,
    ...
}: let
    nhWrapped = pkgs-stable.nh.overrideAttrs {
        postBuild = ''
            wrapProgram $out/bin/nh \
                --prefix PATH : ${lib.makeBinPath [config.nix.package pkgs-stable.nix-output-monitor]}
        '';
    };
in {
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
            nhWrapped
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
