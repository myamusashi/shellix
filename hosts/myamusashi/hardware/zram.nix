{
    zramSwap = {
        enable = true;
        priority = 1;
        algorithm = "lz4";
        memoryPercent = 50;
        memoryMax = 4294967296;
    };

    fileSystems."/".options = ["discard"];
}
