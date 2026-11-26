{
    flake.modules.nixos.nh = {
        config,
        lib,
        pkgs,
        ...
    }: {
        key = "shellix.nixos.nh";

        programs.nh = {
            enable = true;
            package = pkgs.nh.overrideAttrs {
                postBuild = ''
                    wrapProgram $out/bin/nh \
                        --prefix PATH : ${lib.makeBinPath [config.nix.package pkgs.nix-output-monitor]}
                '';
            };
        };
    };
}
