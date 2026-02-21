{lib, ...}: {
    imports = [
        ./audio.nix
        ./earlyoom.nix
        ./geoclue2.nix
        ./resolver.nix
        ./scx.nix
        ./borg.nix
        ./plasma.nix
        ./display-manager.nix
        ./minidlna.nix
    ];

    options.shellix.services.nixos = {
        audio.enable = lib.mkEnableOption "Enable audio using pipewire";
        backup = {
            waltz.enable = lib.mkEnableOption "Enable waltz backup services using Borg";
            myamusashi.enable = lib.mkEnableOption "Enable myamusashi backup services using Borg";
        };
        earlyoom.enable = lib.mkEnableOption "Enable kill early OOM scheduler";
        geoclue2.enable = lib.mkEnableOption "Enable locations";
        resolver.enable = lib.mkEnableOption "Enable resolver using Cloudflare";
        scx.enable = lib.mkEnableOption "Enable scx framework scheduler";
        plasma.enable = lib.mkEnableOption "Enable plasma GUI";
        display-manager = {
            greetd.enable = lib.mkEnableOption "Enable greetd display manager";
            sddm.enable = lib.mkEnableOption "Enable SDDM display manager";
        };
        minidlna.enable = lib.mkEnableOption "Enable MiniDLNA";
    };
}
