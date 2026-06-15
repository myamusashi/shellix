{
    config,
    pkgs,
    ...
}: let
    sopss = config.sops.secrets;
in {
    users = {
        users = {
            myamusashi = {
                isNormalUser = true;
                hashedPasswordFile = sopss.myamusashi-password.path;
                shell = pkgs.fish;
                home = "/home/myamusashi";
                extraGroups = [
                    "networkmanager"
                    "wheel"
                    "docker"
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
                ];
            };

            greeter = {
                isSystemUser = true;
                group = "greeter";
            };

            docker = {
                isSystemUser = true;
                group = "docker";
            };

            nginx = {
                isSystemUser = true;
                group = "nginx";
            };
        };
        groups = {
            docker = {};
            greeter = {};
            nginx = {};
        };
    };
}
