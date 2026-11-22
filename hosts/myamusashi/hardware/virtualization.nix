{
    virtualisation = {
        libvirtd.enable = true;
        docker.enable = false;
        podman.enable = false;
        vmware = {
            host.enable = false;
            guest = {
                enable = true;
                headless = false;
            };
        };
    };
}
