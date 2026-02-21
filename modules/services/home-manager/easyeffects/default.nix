{
    config,
    lib,
    ...
}: {
    config = lib.mkIf config.shellix.services.home-manager.easyeffects.enable {
        services.easyeffects = {
            enable = true;
            preset = "earphone-wired";
            extraPresets = {
                earphone-wired = {
                    output = {
                        blocklist = [];

                        equalizer = {
                            input-gain = 0.0;
                            mode = "IIR";
                            num-bands = 5;
                            split-channels = false;
                            output-gain = 0.0;
                            left = {
                                band0 = {
                                    type = "Low-shelf";
                                    frequency = 80.0;
                                    gain = 2.5;
                                    q = 0.7;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                                band1 = {
                                    type = "Bell";
                                    frequency = 200.0;
                                    gain = -1.5;
                                    q = 1.0;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                                band2 = {
                                    type = "Bell";
                                    frequency = 2500.0;
                                    gain = 2.0;
                                    q = 1.2;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                                band3 = {
                                    type = "Bell";
                                    frequency = 5000.0;
                                    gain = -1.0;
                                    q = 2.0;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                                band4 = {
                                    type = "Hi-shelf";
                                    frequency = 9000.0;
                                    gain = 1.5;
                                    q = 0.8;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                            };
                            right = {
                                band0 = {
                                    type = "Low-shelf";
                                    frequency = 80.0;
                                    gain = 2.5;
                                    q = 0.7;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                                band1 = {
                                    type = "Bell";
                                    frequency = 200.0;
                                    gain = -1.5;
                                    q = 1.0;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                                band2 = {
                                    type = "Bell";
                                    frequency = 2500.0;
                                    gain = 2.0;
                                    q = 1.2;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                                band3 = {
                                    type = "Bell";
                                    frequency = 5000.0;
                                    gain = -1.0;
                                    q = 2.0;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                                band4 = {
                                    type = "Hi-shelf";
                                    frequency = 9000.0;
                                    gain = 1.5;
                                    q = 0.8;
                                    mode = "RLC (BT)";
                                    mute = false;
                                    solo = false;
                                    slope = "x1";
                                };
                            };
                        };

                        compressor = {
                            mode = "Downward";
                            input-gain = 0.0;
                            output-gain = 0.0;
                            threshold = -24.0;
                            ratio = 1.8;
                            attack = 10.0;
                            release = 200.0;
                            makeup = 0.0;
                            knee = -6.0;
                            sidechain = {
                                mode = "RMS";
                                source = "Middle";
                                lookahead = 0.0;
                                preamp = 0.0;
                                reactivity = 10.0;
                                type = "Feed-forward";
                            };
                        };

                        limiter = {
                            input-gain = 0.0;
                            output-gain = 0.0;
                            threshold = -0.5;
                            lookahead = 5.0;
                            attack = 2.0;
                            release = 5.0;
                            mode = "Herm Thin";
                            dithering = "None";
                            oversampling = "None";
                            stereo-link = 100.0;
                            gain-boost = true;
                            alr = false;
                        };

                        plugins_order = [
                            "equalizer"
                            "compressor"
                            "limiter"
                        ];
                    };
                };
            };
        };
    };
}
