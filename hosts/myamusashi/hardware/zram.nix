{
    zramSwap = {
        enable = true;
        priority = 1;
        algorithm = "zstd";
        memoryPercent = 50;
        memoryMax = null;
    };

    fileSystems."/".options = ["discard"];
}
