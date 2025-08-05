{
  config,
  pkgs,
  lib,
  ...
}: let
  caelestia-src = pkgs.fetchFromGitHub {
    owner = "caelestia-dots";
    repo = "shell";
    rev = "main";
    hash = "sha256-YUQZClf+LA0gpTJfdOg+FSdrJzF9dyDrrFfP1RKPXZc=";
  };
in {
  # Configuration files
  xdg.configFile = {
    "quickshell/caelestia" = {
      source = caelestia-src;
      recursive = true;
    };
  };

  home.sessionVariables = {
    C_DATA = "${config.xdg.dataHome}/caelestia";
    C_STATE = "${config.xdg.stateHome}/caelestia";
    C_CACHE = "${config.xdg.cacheHome}/caelestia";
    C_CONFIG = "${config.xdg.configHome}/caelestia";
  };

  home.activation.caelestiaSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Create required directories
    mkdir -p ${config.xdg.dataHome}/caelestia
    mkdir -p ${config.xdg.stateHome}/caelestia/scheme
    mkdir -p ${config.xdg.cacheHome}/caelestia/thumbnails
    mkdir -p ${config.xdg.configHome}/caelestia

    # Ensure state files are writable (fix permission issues)
    if [ -d ${config.xdg.stateHome}/caelestia/scheme ]; then
      find ${config.xdg.stateHome}/caelestia/scheme -name "*.txt" -exec chmod u+w {} \; 2>/dev/null || true
    fi
  '';
}
