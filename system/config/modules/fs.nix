{lib, ...}: {
  zramSwap = {
    enable = false;
    priority = 1;
    algorithm = "zstd";
    memoryPercent = 50;
    memoryMax = null;
  };
  swapDevices = lib.mkForce [];
}
