{
    lib,
    pkgs,
    config,
    ...
}: {
    config = lib.mkIf config.shellix.services.audio.enable {
        security.rtkit.enable = true;

        boot.extraModprobeConfig = ''
            options snd_hda_intel power_save=0
        '';

        services = {
            thermald.enable = true;
            pipewire = {
                enable = true;
                alsa.enable = true;
                pulse.enable = true;
                jack.enable = false;

                extraConfig = {
                    pipewire = {
                        "92-low-latency" = {
                            "context.properties" = {
                                "default.clock.rate" = 48000;
                                "default.clock.quantum" = 1024;
                                "default.clock.min-quantum" = 512;
                                "default.clock.max-quantum" = 4096;
                                "default.clock.allowed-rates" = [48000];
                            };
                        };

                        "98-eq" = {
                            "context.modules" = [
                                {
                                    name = "libpipewire-module-filter-chain";
                                    args = {
                                        "node.description" = "Equalizer Sink";
                                        "media.name" = "Equalizer Sink";
                                        "filter.graph" = {
                                            nodes = [
                                                {
                                                    type = "builtin";
                                                    name = "eq";
                                                    label = "param_eq";
                                                    config.filters = [
                                                        {
                                                            type = "bq_lowshelf";
                                                            freq = 80;
                                                            gain = 2.0;
                                                            q = 0.7;
                                                        }
                                                        {
                                                            type = "bq_peaking";
                                                            freq = 3000;
                                                            gain = -1.5;
                                                            q = 1.0;
                                                        }
                                                        {
                                                            type = "bq_highshelf";
                                                            freq = 9000;
                                                            gain = 1.0;
                                                            q = 0.7;
                                                        }
                                                    ];
                                                }
                                            ];
                                        };
                                        "audio.channels" = 2;
                                        "audio.position" = ["FL" "FR"];
                                        "capture.props" = {
                                            "node.name" = "effect_input.eq";
                                            "media.class" = "Audio/Sink";
                                        };
                                        "playback.props" = {
                                            "node.name" = "effect_output.eq";
                                            "node.passive" = true;
                                        };
                                    };
                                }
                            ];
                        };

                        "99-input-denoising" = {
                            "context.modules" = [
                                {
                                    name = "libpipewire-module-filter-chain";
                                    args = {
                                        "node.description" = "Noise Canceling source";
                                        "media.name" = "Noise Canceling source";
                                        "filter.graph" = {
                                            nodes = [
                                                {
                                                    type = "ladspa";
                                                    name = "rnnoise";
                                                    plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                                                    label = "noise_suppressor_mono";
                                                    control = {
                                                        "VAD Threshold (%)" = 50.0;
                                                        "VAD Grace Period (ms)" = 200;
                                                        "Retroactive VAD Grace (ms)" = 0;
                                                    };
                                                }
                                            ];
                                        };
                                        "capture.props" = {
                                            "node.name" = "capture.rnnoise_source";
                                            "node.passive" = true;
                                            "audio.rate" = 48000;
                                            "target.object" = "alsa_input.pci-0000_00_1f.3.analog-stereo";
                                        };
                                        "playback.props" = {
                                            "node.name" = "rnnoise_source";
                                            "media.class" = "Audio/Source";
                                            "audio.rate" = 48000;
                                        };
                                    };
                                }
                            ];
                        };
                    };

                    pipewire-pulse = {
                        "92-pulse-latency" = {
                            "pulse.properties" = {
                                "pulse.min.quantum" = "512/48000";
                                "pulse.default.quantum" = "1024/48000";
                                "pulse.min.req" = "512/48000";
                                "pulse.default.req" = "1024/48000";
                                "pulse.min.frag" = "512/48000";
                                "pulse.default.frag" = "1024/48000";
                            };
                            "stream.properties" = {
                                "node.latency" = "1024/48000";
                                "resample.quality" = 4;
                            };
                        };

                        "92-zen-rename" = {
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
        };
    };
}
