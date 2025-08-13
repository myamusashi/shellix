{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.shellix.services.nixos.geoclue2.enable {
    services.geoclue2 = {
      enable = true;
      enableWifi = false;
    };
  };
}
