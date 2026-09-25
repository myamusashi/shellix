{config, ...}: let
    sopss = config.sops.secrets;
in {
    users = {
        users = {
            myamusashi = {
                isNormalUser = true;
                hashedPasswordFile = sopss.myamusashi-password.path;
                home = "/home/myamusashi";
                extraGroups = [
                    "networkmanager"
                    "wheel"
                    "podman"
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
        groups = {
            docker = {};
            nginx = {};
        };
    };
}
