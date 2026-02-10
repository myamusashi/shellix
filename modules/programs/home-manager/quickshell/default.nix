{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.shellix.programs.home.quickshell;

  quickshell-wrapped =
    pkgs.runCommand "quickshell-wrapped" {
      nativeBuildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      mkdir -p $out/lib
      cp -r ${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/qt-6/qml/Quickshell $out/lib/Quickshell

      makeWrapper ${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/qs $out/bin/qs \
        --prefix PATH : ${lib.makeBinPath [pkgs.fd pkgs.coreutils]}

      makeWrapper ${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/quickshell $out/bin/quickshell \
        --prefix PATH : ${lib.makeBinPath [pkgs.fd pkgs.coreutils]}
    '';
in {
  config = lib.mkIf cfg.enable {
    programs.quickshell = {
      enable = true;
      package = quickshell-wrapped;
    };
  };
}
