{
    lib,
    config,
    ...
}: {
    config = lib.mkIf config.shellix.services.server.vsftpd.enable {
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
