{
    config,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.services.audio.enable {
        security.rtkit.enable = true;
        services.thermald.enable = true;

        boot.extraModprobeConfig = ''
            options snd_hda_intel power_save=0
        '';

        services.pipewire = {
            enable = true;
            alsa.enable = true;
            pulse.enable = true;
            jack.enable = false;

            extraConfig = {
                pipewire."92-low-latency" = {
                    "context.properties" = {
                        "default.clock.rate" = 48000;
                        "default.clock.quantum" = 2048;
                        "default.clock.min-quantum" = 2048;
                        "default.clock.max-quantum" = 4096;
                        "default.clock.allowed-rates" = [48000];
                    };
                };

                pipewire."10-rt-module" = {
                    "context.modules" = [
                        {
                            name = "libpipewire-module-rt";
                            args = {
                                "nice.level" = -11;
                                "rt.prio" = 88;
                                "rt.time.soft" = 200000;
                                "rt.time.hard" = 200000;
                            };
                            flags = [
                                "ifexists"
                                "nofail"
                            ];
                        }
                    ];
                };

                pipewire-pulse."92-pulse-latency" = {
                    "pulse.properties" = {
                        "pulse.min.quantum" = "2048/48000";
                        "pulse.default.quantum" = "2048/48000";
                        "pulse.min.req" = "2048/48000";
                        "pulse.default.req" = "2048/48000";
                        "pulse.min.frag" = "2048/48000";
                        "pulse.default.frag" = "2048/48000";
                    };
                    "stream.properties" = {
                        "node.latency" = "2048/48000";
                        "resample.quality" = 4;
                    };
                };

                pipewire-pulse."92-zen-rename" = {
                    # pulse.rules only rewrites the PA *client* object, not the
                    # per-stream properties Zen re-sets on every playback stream.
                    # stream.rules operates on the actual stream/Node properties,
                    # which is what pw-dump / mixers / shells actually read.
                    "stream.rules" = [
                        {
                            matches = [
                                {
                                    "application.process.binary" = "zen";
                                }
                            ];
                            actions = {
                                "update-props" = {
                                    "application.name" = "Zen";
                                    "node.description" = "Zen";
                                    "node.name" = "Zen";
                                    "application.icon-name" = "zen-browser";
                                };
                            };
                        }
                    ];
                };
            };
        };
    };
}
