{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./packages.nix # Caelestia scripts and quickshell wrapper derivations
    # ./config.nix # Configuration files and environment setup
  ];

  # Main packages
  home.packages = with pkgs; [
    config.programs.quickshell.finalPackage # Our wrapped quickshell
    # Qt dependencies
    qt6.qt5compat
    qt6.qtdeclarative

    # Runtime dependencies
    hyprpaper
    imagemagick
    wl-clipboard
    fuzzel
    socat
    foot
    jq
    python3
    python3Packages.materialyoucolor
    grim
    wayfreeze
    wl-screenrec
    inputs.astal.packages.${pkgs.system}.default

    # Additional dependencies
    lm_sensors
    curl
    material-symbols
    nerd-fonts.jetbrains-mono
    ibm-plex
    fd
    python3Packages.pyaudio
    python3Packages.numpy
    cava
    networkmanager
    bluez
    ddcutil
    brightnessctl
  ];

  # Systemd service
  systemd.user.services.kurukuru-bar = {
    Unit = {
      Description = "kurukuru-bar desktop shell";
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "exec";
      ExecStart = "${config.programs.quickshell.finalPackage}/bin/qs -c kurukuru";
      Restart = "on-failure";
      Slice = "app-graphical.slice";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
