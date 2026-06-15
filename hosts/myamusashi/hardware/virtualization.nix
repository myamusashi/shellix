{
    virtualisation = {
        libvirtd.enable = true;
        podman = {
            enable = true;
            dockerCompat = true;
            dockerSocket.enable = true;
            defaultNetwork.settings.dns_enabled = true;
        };
        vmware = {
            host.enable = false;
            guest = {
                enable = true;
                headless = false;
            };
        };
    };
}
