{inputs, ...}: {
    imports = [inputs.areofyl-fetch.homeManagerModules.default];

    programs.fetch = {
        enable = true;
        labelColor = "red";
        info = [
            "os"
            "host"
            "kernel"
            "uptime"
            "packages"
            "shell"
            "wm"
            "font"
            "terminal"
        ];
        speed = 1.0;
        spin = "xy";
    };
}
