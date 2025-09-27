{lib, ...}: {
  imports = [
    ./fish/default.nix
    ./steam/default.nix
    ./xonsh/default.nix
    ./starship/default.nix
    ./wireshark/default.nix
    ./virt-manager/default.nix
  ];

  # TODO: Move enable to this instead
  options.shellix.programs.nixos = {
    fish.enable = lib.mkEnableOption "Enable fish shell";
    starship.enable = lib.mkEnableOption "Enable starship shell theming";
    steam.enable = lib.mkEnableOption "Enable steam games";
    virt-manager.enable = lib.mkEnableOption "Enable virt-manager kvm virtual machine";
    wireshark.enable = lib.mkEnableOption "Enable wireshark network spoofing";
    xonsh.enable = lib.mkEnableOption "Enable xonsh shell";
  };
}
