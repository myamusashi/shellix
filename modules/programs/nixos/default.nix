{lib, ...}: {
    imports = [
        ./fish/default.nix
        ./steam/default.nix
        ./xonsh/default.nix
        ./wireshark/default.nix
        ./virt-manager/default.nix
    ];

    options.shellix.programs.nixos = {
        fish.enable = lib.mkEnableOption "Enable fish shell";
        steam.enable = lib.mkEnableOption "Enable steam games";
        virt-manager.enable = lib.mkEnableOption "Enable virt-manager kvm virtual machine";
        wireshark.enable = lib.mkEnableOption "Enable wireshark network spoofing";
        xonsh.enable = lib.mkEnableOption "Enable xonsh shell";
    };
}
