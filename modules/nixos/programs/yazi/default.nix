{
    config,
    lib,
    pkgs,
    inputs,
    ...
}: let
    cfg = config.shellix.programs.yazi;
    yazi-plugins = inputs.yazi-plugins-flakes.packages.${pkgs.stdenv.hostPlatform.system};

    yaziToml = ''
        [preview]
        image_filter = "catmull-rom"
        image_quality = 80

        [theme]
        flavor = { dark = "shellix" }

        [opener]
        openImage = [
            { run = 'lximage-qt "$@"', block = true, for = "unix" }
        ]
        openPdf = [
            { run = '${pkgs.zathura}/bin/zathura "$@"', block = true, for = "unix" }
        ]
        extract = [
            { run = 'ouch d -y "$@"', desc = "Extract here with ouch", for = "unix" }
        ]

        [open]
        prepend_rules = [
            { url = "*.{svg,png,jpg,jpeg,gif}", use = "openImage" },
            { url = "*.pdf", use = "openPdf" }
        ]

        [plugin]
        prepend_fetchers = [
            { group = "git", url = "*", run = "git" },
            { group = "git", url = "*/", run = "git" }
        ]
        prepend_preloaders = [
            { mime = "{audio,video,image}/*", run = "mediainfo" },
            { mime = "application/subrip", run = "mediainfo" },
            { mime = "application/openxmlformats-officedocument.*", run = "office" },
            { mime = "application/oasis.opendocument.*", run = "office" },
            { mime = "application/ms-*", run = "office" },
            { mime = "application/msword", run = "office" },
            { url = "*.docx", run = "office" }
        ]
        prepend_previewers = [
            { url = "*/", run = "eza-preview" },
            { mime = "{audio,video}/*", run = "mediainfo" },
            { url = "*.{jpg,png,webp}", run = "mediainfo" },
            { mime = "application/subrip", run = "mediainfo" },
            { url = "*.csv", run = "rich-preview" },
            { url = "*.md", run = "rich-preview" },
            { url = "*.rst", run = "rich-preview" },
            { url = "*.ipynb", run = "rich-preview" },
            { url = "*.json", run = "rich-preview" },
            { mime = "application/openxmlformats-officedocument.*", run = "office" },
            { mime = "application/oasis.opendocument.*", run = "office" },
            { mime = "application/ms-*", run = "office" },
            { mime = "application/msword", run = "office" },
            { url = "*.docx", run = "office" },
            { mime = "application/*zip", run = "ouch" },
            { mime = "application/x-tar", run = "ouch" },
            { mime = "application/x-tar.gz", run = "ouch" },
            { mime = "application/x-bzip2", run = "ouch" },
            { mime = "application/x-7z-compressed", run = "ouch" },
            { mime = "application/x-rar", run = "ouch" },
            { mime = "application/x-xz", run = "ouch" }
        ]
    '';

    keymapToml = ''
        [manager]
        show_symlink = true
        prepend_keymap = [
            { on = [ "'", ";" ], run = "plugin custom-shell -- fish --interactive" },
            { on = [ "<C-s>" ], run = "plugin kdeconnect-send", desc = "Send selected files via KDE Connect" },
            { on = [ "E" ], run = "plugin eza-preview", desc = "Toggle tree/list dir preview" },
            { on = [ "-" ], run = "plugin eza-preview '--inc-level'", desc = "Increment tree level" },
            { on = [ "_" ], run = "plugin eza-preview '--dec-level'", desc = "Decrement tree level" },
            { on = [ "$" ], run = "plugin eza-preview '--toggle-follow-symlinks'", desc = "Toggle tree follow symlinks" },
            { on = [ "<C-d>" ], run = "plugin diff", desc = "Diff the selected with the hovered file" },
            { on = [ "g", "i" ], run = "plugin lazygit", desc = "run lazygit" },
            { on = [ "T" ], run = "plugin toggle-pane min-preview", desc = "Hide or show preview" },
            { on = [ "M" ], run = "plugin mount" },
            { on = [ "<C-e>" ], run = "seek 5" },
            { on = [ "<C-y>" ], run = "seek -5" },
            { on = [ "f", "g" ], run = "plugin fg", desc = "find file by content" },
            { on = [ "f", "f" ], run = "plugin fg 'fzf'", desc = "find file by filename" },
            { on = [ "f", "G" ], run = "plugin fg 'rg'", desc = "find file by content (ripgrep match)" },
            { on = [ "C" ], run = "plugin ouch zip", desc = "Compress with ouch" }
        ]
    '';
in {
    config = lib.mkIf cfg.enable {
        environment.systemPackages = [pkgs.yazi];

        systemd.user.tmpfiles.rules = [
            "d %h/.config 0755 myamusashi users - -"
            "d %h/.config/yazi 0755 myamusashi users - -"
            "d %h/.config/yazi/plugins 0755 myamusashi users - -"
            "d %h/.config/yazi/flavors 0755 myamusashi users - -"
            "L+ %h/.config/yazi/yazi.toml - - - - ${pkgs.writeText "yazi.toml" yaziToml}"
            "L+ %h/.config/yazi/keymap.toml - - - - ${pkgs.writeText "keymap.toml" keymapToml}"
            "L+ %h/.config/yazi/init.lua - - - - ./init.lua"

            # Plugins symlinks
            "L+ %h/.config/yazi/plugins/chmod - - - - ${yazi-plugins.official-plugins}/chmod.yazi"
            "L+ %h/.config/yazi/plugins/diff - - - - ${yazi-plugins.official-plugins}/diff.yazi"
            "L+ %h/.config/yazi/plugins/full-border - - - - ${yazi-plugins.official-plugins}/full-border.yazi"
            "L+ %h/.config/yazi/plugins/git - - - - ${yazi-plugins.official-plugins}/git.yazi"
            "L+ %h/.config/yazi/plugins/toggle-pane - - - - ${yazi-plugins.official-plugins}/toggle-pane.yazi"
            "L+ %h/.config/yazi/plugins/mount - - - - ${yazi-plugins.official-plugins}/mount.yazi"
            "L+ %h/.config/yazi/plugins/piper - - - - ${yazi-plugins.official-plugins}/piper.yazi"
            "L+ %h/.config/yazi/plugins/office - - - - ${yazi-plugins.office}"
            "L+ %h/.config/yazi/plugins/rich-preview - - - - ${yazi-plugins.rich-preview}"
            "L+ %h/.config/yazi/plugins/eza-preview - - - - ${yazi-plugins.eza-preview}"
            "L+ %h/.config/yazi/plugins/mediainfo - - - - ${yazi-plugins.mediainfo}"
            "L+ %h/.config/yazi/plugins/fg - - - - ${yazi-plugins.fzf}"
            "L+ %h/.config/yazi/plugins/hexyl - - - - ${yazi-plugins.hexyl}"
            "L+ %h/.config/yazi/plugins/ouch - - - - ${yazi-plugins.ouch}"
            "L+ %h/.config/yazi/plugins/yatline - - - - ${yazi-plugins.yatline}"
            "L+ %h/.config/yazi/plugins/lazygit - - - - ${yazi-plugins.lazygit}"
            "L+ %h/.config/yazi/plugins/kdeconnect-send - - - - ${yazi-plugins.kdeconnect-send}"
            "L+ %h/.config/yazi/plugins/custom-shell - - - - ${yazi-plugins.custom-shell}"

            # Flavors symlinks
            "L+ %h/.config/yazi/flavors/kanagawa - - - - ${yazi-plugins.kanagawa}"
            "L+ %h/.config/yazi/flavors/material-ocean - - - - ${yazi-plugins.material-ocean}"
        ];
    };
}
