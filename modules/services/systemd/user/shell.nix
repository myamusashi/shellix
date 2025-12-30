{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  quickshell-wrapped =
    pkgs.runCommand "quickshell-wrapped" {
      nativeBuildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      mkdir -p $out/lib

      cp -r ${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/qt-6/qml/Quickshell $out/lib/Quickshell

      makeWrapper ${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/qs $out/bin/qs \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix QML2_IMPORT_PATH : "$out/lib" \
        --prefix PATH : ${lib.makeBinPath [pkgs.fd pkgs.coreutils]}
    '';
in {
  config = lib.mkIf config.shellix.services.systemd.user.shell.enable {
    systemd.user.services.shell = {
      Unit = {
        Description = "Shell widget using quickshell";
        After = ["hyprland-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = "${quickshell-wrapped}/bin/qs -c lock";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };
      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };
  };
}
