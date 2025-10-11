{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.shellix.programs.home.winboat;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      (inputs.winboat.packages.${pkgs.stdenv.hostPlatform.system}.winboat.overrideAttrs (oldAttrs: {
        postInstall = ''
          cat > $out/share/applications/winboat.desktop <<EOF
              [Desktop Entry]
              Name=WinBoat
              Exec=$out/bin/winboat --enable-features=UseOzonePlatform --ozone-platform=wayland %U
              Type=Application
              Terminal=false
              Icon=winboat
              Categories=Utility;
          EOF
        '';
      }))
    ];
  };
}
