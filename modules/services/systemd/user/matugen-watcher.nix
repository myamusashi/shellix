{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.shellix.services.systemd.user.matugen-watcher;
  matugenScript = pkgs.writeShellScript "matugen-wrapper" ''
    PATH_FILE="$HOME/.cache/wall/path.txt"

    if [ ! -f "$PATH_FILE" ]; then
      echo "Error: $PATH_FILE tidak ditemukan"
      exit 1
    fi

    WALLPAPER_PATH=$(cat "$PATH_FILE")

    if [ ! -f "$WALLPAPER_PATH" ]; then
      echo "Error: Wallpaper file tidak ditemukan: $WALLPAPER_PATH"
      exit 1
    fi

    ${pkgs.matugen}/bin/matugen image "$WALLPAPER_PATH" -t scheme-tonal-spot
  '';
in {
  config = lib.mkIf cfg.enable {
    systemd.user.services.matugen-watcher = {
      Unit = {
        Description = "Matugen wallpaper color scheme generator";
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${matugenScript}";
        RemainAfterExit = false;
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.paths.matugen-watcher = {
      Unit = {
        Description = "Watch for wallpaper path changes";
      };

      Path = {
        PathChanged = "%h/.cache/wall/path.txt";
        Unit = "matugen-watcher.service";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
