{
  lib,
  config,
  pkgs-stable,
  ...
}: {
  config = lib.mkIf config.shellix.services.server.nix-serve.enable {
    services.nix-serve = {
      enable = true;
      package = pkgs-stable.nix-serve-ng;
      port = 5500;
      secretKeyFile = config.sops.secrets.nix-serve_secrets.path;
    };
  };
}
