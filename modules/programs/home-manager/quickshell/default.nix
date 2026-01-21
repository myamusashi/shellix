{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.shellix.programs.home.quickshell;

  getQmlPath = pkg: "${pkg}/${pkgs.qt6.qtbase.qtQmlPrefix}";

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

    home.sessionVariables = {
      QML2_IMPORT_PATH = lib.concatStringsSep ":" [
        "${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/qt-6/qml"
        "${getQmlPath pkgs.qt6.qt5compat}"
        "${getQmlPath pkgs.qt6.qtdeclarative}"
        "${getQmlPath pkgs.qt6.qtmultimedia}"
        "${getQmlPath pkgs.kdePackages.kirigami}"
        "${getQmlPath pkgs.kdePackages.kirigami-addons}"
        "${getQmlPath inputs.m3shapes.packages.${pkgs.stdenv.hostPlatform.system}.m3shapes}"
        "${quickshell-wrapped}/lib"
      ];

      QML_IMPORT_PATH = lib.concatStringsSep ":" [
        "${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/qt-6/qml"
        "${getQmlPath pkgs.qt6.qt5compat}"
        "${getQmlPath pkgs.qt6.qtdeclarative}"
        "${getQmlPath pkgs.qt6.qtmultimedia}"
        "${getQmlPath pkgs.kdePackages.kirigami}"
        "${getQmlPath pkgs.kdePackages.kirigami-addons}"
        "${getQmlPath inputs.m3shapes.packages.${pkgs.stdenv.hostPlatform.system}.m3shapes}"
        "${quickshell-wrapped}/lib"
      ];

      QT_PLUGIN_PATH = lib.concatStringsSep ":" [
        "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}"
        "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtPluginPrefix}"
        "${pkgs.kdePackages.kirigami}/${pkgs.qt6.qtbase.qtPluginPrefix}"
      ];
    };
  };
}
