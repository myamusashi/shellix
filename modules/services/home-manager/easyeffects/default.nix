{
    config,
    lib,
    ...
}: let
    loadPreset = name: builtins.fromJSON (builtins.readFile ./presets/${name}.json);

    presets = {
        earphone-wired = loadPreset "earphone-wired";
        gentle-dynamics = loadPreset "gentle-dynamics";
    };
in {
    options.shellix.services.home-manager.easyeffects.preset = lib.mkOption {
        type = lib.types.enum (builtins.attrNames presets);
        default = "earphone-wired";
    };

    config = lib.mkIf config.shellix.services.home-manager.easyeffects.enable {
        services.easyeffects = {
            enable = true;
            preset = config.shellix.services.home-manager.easyeffects.preset;
            extraPresets = presets;
        };
    };
}
