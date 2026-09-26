{lib, ...}: {
    mkEnable = description:
        lib.mkOption {
            type = lib.types.bool;
            default = false;
            inherit description;
        };

    mkCfg = description: default:
        lib.mkOption {
            type = lib.types.str;
            inherit default description;
        };

    mkIfEnabled = config: path: content:
        lib.mkIf (lib.attrByPath path false config) content;
}
