{
    flake.modules.nixos.colorTemplates = {
        config,
        lib,
        ...
    }: let
        colorTemplatesConfig = config.shellix.colorTemplates;

        templates = [
            {
                input = ../../assets/color-templates/btop/btop.theme;
                output = ".config/btop/themes/shellix.theme";
            }
            {
                input = ../../assets/color-templates/discord/discord-theme.css;
                output = ".config/vesktop/themes/shellix.theme.css";
            }
            {
                input = ../../assets/color-templates/foot/foot.ini;
                output = ".config/foot/foot.ini";
            }
            {
                input = ../../assets/color-templates/gtk/gtk-colors.css;
                output = ".config/gtk-3.0/gtk.css";
            }
            {
                input = ../../assets/color-templates/gtk/gtk-colors.css;
                output = ".config/gtk-4.0/gtk.css";
            }
            {
                input = ../../assets/color-templates/hyprland/colors.lua;
                output = ".config/hypr/colors-hypr-matugen.lua";
            }
            {
                input = ../../assets/color-templates/kitty/kitty-colors.conf;
                output = ".config/kitty/shellix.conf";
            }
            {
                input = ../../assets/color-templates/kvantum/kvantum.kvconfig;
                output = ".config/Kvantum/Shellix-matugen/Shellix-matugen.kvconfig";
            }
            {
                input = ../../assets/color-templates/color-scheme/Shellix.colors;
                output = ".local/share/color-schemes/Shellix.colors";
            }
            {
                input = ../../assets/color-templates/lazygit/lazygit-theme.yml;
                output = ".config/lazygit/config.yml";
            }
            {
                input = ../../assets/color-templates/qtct/qtct-colors.conf;
                output = ".config/qt6ct/colors/shellix.conf";
            }
            {
                input = ../../assets/color-templates/starship/starship.colors;
                output = ".config/starship.toml";
            }
            {
                input = ../../assets/color-templates/yazi/yazi-theme.conf;
                output = ".config/yazi/flavors/shellix.yazi/flavor.toml";
            }
            {
                input = ../../assets/color-templates/zellij/zellij-colors.kdl;
                output = ".config/zellij/themes/shellix.kdl";
            }
            {
                input = ../../assets/color-templates/loaf-theme/colors.json;
                output = ".local/state/quickshell/user/generated/colors.json";
            }
            {
                input = ../../assets/color-templates/zapfast/shellix.json;
                output = ".config/zapfast/Shellix.json";
            }
            {
                input = ../../assets/color-templates/serein/shellix.json;
                output = ".config/serein/shellix.json";
            }
            {
                input = ../../assets/color-templates/yapfast/layout.json;
                output = ".local/share/yapfast/layout.json";
            }
        ];

        outputDirectories = lib.unique (map (template: builtins.dirOf template.output) templates);
        directoryRules = map (directory: "d %h/${directory} 0755 - - - -") outputDirectories;
        templateRules = map (template: "L+ %h/${template.output}.tmpl - - - - ${template.input}") templates;

        # Upserts the zen chrome/content template entries into vast-shell's
        # templates.json by name so hand-curated entries survive, then renders once.
        zenSyncBlocks =
            lib.concatImapStrings (
                index: profile: let
                    suffix =
                        if lib.length colorTemplatesConfig.zenProfiles == 1
                        then ""
                        else "-${toString index}";
                in ''
                    # --- zen profile: ${profile} ---
                    entries=$(jq -cn --arg home "$HOME" --arg profile "${profile}" '
                      [
                        {name: "zen-chrome-colors${suffix}", input: ($home+"/"+$profile+"/chrome/sine-mods/zen-matugen/chrome.css.tmpl"), post_hook: "", enabled: true},
                        {name: "zen-content-colors${suffix}", input: ($home+"/"+$profile+"/chrome/sine-mods/zen-matugen/content.css.tmpl"), post_hook: "", enabled: true}
                      ]')
                    jq --argjson entries "$entries" \
                      '.templates = ((.templates // []) | map(select(.name | IN($entries[].name) | not)) + $entries)' \
                      "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
                ''
            )
            colorTemplatesConfig.zenProfiles;
    in {
        options.shellix.colorTemplates.zenProfiles = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Zen profile paths (relative to HOME, e.g. \".zen/kxhdnjqx.zen\") whose chrome/content colors render through vastctl.";
        };

        config = {
            systemd.user.tmpfiles.rules =
                directoryRules
                ++ templateRules
                ++ [
                    "L+ %h/.config/Kvantum/Shellix-matugen/Shellix-matugen.svg - - - - ${../../assets/color-templates/kvantum/MaterialAdw.svg}"
                ];

            systemd.user.services.vast-templates-zen-sync = {
                wantedBy = ["default.target"];
                serviceConfig = {
                    Type = "oneshot";
                    RemainAfterExit = true;
                };
                script = ''
                    cfg="''${XDG_CONFIG_DIR:-$HOME/.config}/vast-shell/templates.json"
                    mkdir -p "$(dirname "$cfg")"
                    [ -s "$cfg" ] || printf '{"templates":[]}\n' > "$cfg"
                    ${zenSyncBlocks}
                    vastctl colors render || true
                '';
            };
        };
    };
}
