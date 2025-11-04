{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.shellix.services.nixos.earlyoom.enable {
    services.earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemKillThreshold = 6; # Kill at 6% free (~1GB)
      freeSwapKillThreshold = 6; # Kill at 6% free (~500MB)
    };
  };
}
