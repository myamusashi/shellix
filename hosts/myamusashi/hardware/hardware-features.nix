{...}: {
    hardware = {
        sensor.iio.enable = true;
        i2c.enable = true;
        acpilight.enable = true;
        bluetooth = {
            enable = true;
            powerOnBoot = true;
        };
    };
}
