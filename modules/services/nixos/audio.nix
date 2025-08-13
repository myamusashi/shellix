{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.shellix.services.nixos.audio.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      audio.enable = true;
      extraConfig.pipewire = {
        "10-clock-rate" = {
          "context.properties" = {
            "default.clock.min-quantum" = 1024;
          };
        };
      };
    };
  };
}
