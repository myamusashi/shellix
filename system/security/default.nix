{
  security = {
    rtkit.enable = true;

    polkit.enable = true;

    wrappers.ubridge = {
      source = "/run/current-system/sw/bin/ubridge";
      capabilities = "cap_net_admin,cap_net_raw=ep";
      owner = "root";
      group = "ubridge";
      permissions = "u+rx,g+rx,o+rx";
    };
  };
}
