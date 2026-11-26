{
    flake.modules.nixos.coreBase = {
        key = "shellix.nixos.coreBase";

        time.timeZone = "Asia/Jakarta";
        i18n.defaultLocale = "en_US.UTF-8";

        # Disabling NixOS manual HTML/doc generation avoids evaluating every module option tree.
        documentation.nixos.enable = false;

        nixpkgs.config.allowUnfree = true;
    };
}
