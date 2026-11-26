{
    flake.modules.nixos.myamusashiUsers = {config, ...}: {
        key = "shellix.nixos.myamusashiUsers";

        users = {
            users = {
                myamusashi = {
                    isNormalUser = true;
                    hashedPasswordFile = config.sops.secrets.myamusashi-password.path;
                    home = "/home/myamusashi";
                    extraGroups = [
                        "networkmanager"
                        "wheel"
                        "microvm"
                        "libvirtd"
                        "qemu-libvirtd"
                        "kvm"
                        "adbusers"
                        "video"
                        "render"
                        "input"
                        "seat"
                        "wireshark"
                        "i2c"
                        "greeter"
                    ];
                };

                nginx = {
                    isSystemUser = true;
                    group = "nginx";
                };
            };

            groups.nginx = {};
        };
    };
}
