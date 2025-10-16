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

      cp -r ${inputs.quickshell.packages.${pkgs.system}.default}/lib/qt-6/qml/Quickshell $out/lib/Quickshell

      makeWrapper ${inputs.quickshell.packages.${pkgs.system}.default}/bin/qs $out/bin/qs \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix QML2_IMPORT_PATH : "$out/lib" \
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
