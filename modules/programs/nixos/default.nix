{lib, ...}: {
  imports = [
    ./fish/default.nix
    ./steam/default.nix
    ./xonsh/default.nix
    ./starship/default.nix
    ./wireshark/default.nix
    ./virt-manager/default.nix
  ];

  options.shellix.programs.nixos = {
    enable = lib.mkEnableOption "Enable nixos programs";
  };
}
