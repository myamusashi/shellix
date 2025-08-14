{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.services.nixos.backup;
in {
  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs.waltz-server = {
      paths = "/var/lib";
      encryption.mode = "none";
      repo = "/opt/backup";
      compression = "auto,zstd";
      startAt = "weekly";
    };
  };
}
