{
    lib,
    pkgs,
    ...
}: {
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
        ./systemd/cachix.nix
        ./systemd/stirling.nix
        ./systemd/cloudflare-tunnels.nix
        ./kdeconnect.nix
        ./forgejo-runner.nix
        ./clipse.nix
        ./easyeffects/default.nix
        ./kbuildsycoca6.nix
        ./hypridle.nix
        ./mpd.nix
        ./systemd/nm-applet.nix
    ];

    options.shellix.services = {
        audio.enable = lib.mkEnableOption "Enable audio using pipewire";
        earlyoom.enable = lib.mkEnableOption "Enable kill early OOM scheduler";
        geoclue2.enable = lib.mkEnableOption "Enable locations";
        resolver.enable = lib.mkEnableOption "Enable resolver using Cloudflare";
        scx.enable = lib.mkEnableOption "Enable scx framework scheduler";
        plasma.enable = lib.mkEnableOption "Enable plasma GUI";
        minidlna.enable = lib.mkEnableOption "Enable MiniDLNA";
        display-manager = {
            greetd.enable = lib.mkEnableOption "Enable greetd display manager";
            sddm.enable = lib.mkEnableOption "Enable SDDM display manager";

            greetd = {
                package = lib.mkPackageOption pkgs "greetd" {
                    default = pkgs.greetd.greetd;
                    description = "What Greetd package you want to use";
                };
                virtual-console = lib.mkOption {
                    type = lib.types.int;
                    default = 1;
                    example = 6;
                    description = "What TTY you want to occupy (this will remove the TTY you choose)";
                };
                auto-login = {
                    enable = lib.mkEnableOption "Enable auto login";
                    runner = lib.mkOption {
                        type = lib.types.str;
                        default = "Hyprland";
                        example = "sway";
                        description = "What command to use for running the session";
                    };
                    user = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        example = "user1";
                        description = "Username for auto login";
                    };
                };
                greeter = lib.mkOption {
                    type = lib.types.str;
                    default = "tuigreet";
                    example = "agreety";
                    description = "Which greeter to use";
                };
                flags = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [];
                    example = [
                        "--remember-user-session"
                        "--time"
                    ];
                    description = "Additional flags for the greeter";
                };
            };
            sddm = {
                wayland = {
                    enable = lib.mkEnableOption "Enable SDDM for wayland";
                    compositor = lib.mkOption {
                        type = lib.types.str;
                        default = "weston";
                        example = "kwin";
                        description = "Choose your compositor to use";
                    };
                };
                theme = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    example = "sugar-candy";
                    description = "What SDDM theme you want to use";
                };
                auto-login = {
                    enable = lib.mkEnableOption "Enable auto login";
                    user = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        example = "user1";
                        description = "User for auto login";
                    };
                    session = lib.mkOption {
                        type = lib.types.str;
                        default = "plasma.desktop";
                        example = "hyprland.desktop";
                        description = "Session to auto-login to";
                    };
                };
            };
        };
        backup = {
            waltz.enable = lib.mkEnableOption "Enable waltz backup services using Borg";
            myamusashi.enable = lib.mkEnableOption "Enable myamusashi backup services using Borg";

            user = lib.mkOption {
                default = "";
                description = "Username for your backup name";
                type = lib.types.str;
            };

            settings = lib.mkOption {
                default = {};
                description = "Configuration for your backup";
                type = lib.types.attrsOf (
                    lib.types.submodule (
                        {name, ...}: {
                            options = {
                                repo = lib.mkOption {
                                    default = "";
                                    description = "Directory for your backup, you can use ssh connection to backup your files/directory";
                                    example = ''
                                        repo = "waltz@10.0.0.10:/backup/myamusashi";
                                    '';
                                    type = lib.types.str;
                                };
                            };
                        }
                    )
                );
            };
        };
        easyeffects = {
            enable = lib.mkEnableOption "Enable audio I/O manager";
        };
        kdeconnect.enable = lib.mkEnableOption "Enable kde-connect";
        forgejo-runner.enable = lib.mkEnableOption "Enable Forgejo runners";
        clipse.enable = lib.mkEnableOption "Enable clipboard manager";
        kbuildsycoca6.enable = lib.mkEnableOption "Enable KDE build system cache (fixes Dolphin Open With)";
        hypridle.enable = lib.mkEnableOption "Enable idle manager";
        mpd.enable = lib.mkEnableOption "Enable MPD players services";

        systemd = {
            cachix.enable = lib.mkEnableOption "Enable cachix daemon";
            stirling.enable = lib.mkEnableOption "Enable stirling PDF services";
            cloudflare-tunnels.enable = lib.mkEnableOption "Enable cloudflare-tunnels keys for running cloudflare services";
            nm-applet.enable = lib.mkEnableOption "Enable network manger applet tray widgets";
        };
    };
}
