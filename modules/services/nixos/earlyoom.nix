{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.shellix.services.nixos.earlyoom.enable {
    services.earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemKillThreshold = 2;
      freeSwapKillThreshold = 3;
    };
  };
}
