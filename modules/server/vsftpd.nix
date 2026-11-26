{
    flake.modules.nixos.vsftpd = {
        key = "shellix.nixos.vsftpd";

        services.vsftpd = {
            enable = true;
            writeEnable = true;
            localUsers = true;
            localRoot = "/var/ftp";
            extraConfig = ''
                local_umask=007
            '';
        };
    };
}
