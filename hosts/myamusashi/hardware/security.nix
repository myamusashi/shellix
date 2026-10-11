{pkgs, ...}: {
    security = {
        wrappers = {
            gsr-kms-server = {
                source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
                capabilities = "cap_sys_admin+ep";
                owner = "root";
                group = "root";
            };
            intel_gpu_top = {
                source = "${pkgs.intel-gpu-tools}/bin/intel_gpu_top";
                capabilities = "cap_perfmon+ep";
                owner = "myamusashi";
                group = "root";
            };
        };
        pam.services.greetd.text = ''
            auth      substack      login
            account   include       login
            password  substack      login
            session   include       login
        '';
        apparmor.enable = true;
    };

    services.fwupd.enable = true;
}
