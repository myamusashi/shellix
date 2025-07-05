final: prev: {
  upower = prev.upower.overrideAttrs (oldAttrs: {
    doCheck = false;
  });

  material-symbols = prev.material-symbols.overrideAttrs (oldAttrs: {
    version = "4.0.0-unstable-2025-04-11";

    src = final.fetchFromGitHub {
      owner = "google";
      repo = "material-design-icons";
      rev = "941fa95d7f6084a599a54ca71bc565f48e7c6d9e";
      hash = "sha256-5bcEh7Oetd2JmFEPCcoweDrLGQTpcuaCU8hCjz8ls3M=";
      sparseCheckout = ["variablefont"];
    };
  });

  vmware-modules = prev.stdenv.mkDerivation {
    pname = "vmware-modules";
    # The 'prev.kernel' ensures we build against the kernel NixOS is configured to use.
    version = "workstation-17.6.3-20250608-${prev.kernel.version}";

    src = prev.fetchFromGitHub {
      owner = "philipl";
      repo = "vmware-host-modules";
      # This rev corresponds to VMware Workstation 17.5.2, not 17.6.3 as in your version string.
      # You may need to update rev, version, and hash for the version you want.
      rev = "e08764f84df3bd14407291e02346b7c5c54d0bf6";
      hash = "sha256-RDVKropC+VOv1uJijOGlLt6iqZI8Cm9aWlbmvZj2CSk=";
    };

    # The rest of your derivation logic is mostly the same,
    # but we reference dependencies using 'prev' (e.g., prev.kmod).
    hardeningDisable = ["pic"];
    nativeBuildInputs = prev.kernel.moduleBuildDependencies;
    enableParallelBuilding = true;
    postPatch = ''
      substituteInPlace Makefile \
        --replace '/lib/modules/$(VM_UNAME)/misc' "$out/lib/modules/${prev.kernel.modDirVersion}/misc" \
        --replace /sbin/modinfo "${prev.kmod}/bin/modinfo" \
        --replace 'test -z "$(DESTDIR)"' "0"
      for module in "vmmon-only" "vmnet-only"; do
        substituteInPlace "./$module/Makefile" \
          --replace '/lib/modules/' "${prev.kernel.dev}/lib/modules/" \
          --replace /bin/grep "${prev.gnugrep}/bin/grep"
      done
    '';
    preInstall = ''
      mkdir -p "$out/lib/modules/${prev.kernel.modDirVersion}/misc"
    '';

    meta = with prev.lib; {
      description = "Kernel modules needed for VMware hypervisor";
      homepage = "https://github.com/mkubecek/vmware-host-modules";
      license = licenses.gpl2Only;
      platforms = ["x86_64-linux"];
      broken = prev.kernel.kernelOlder "5.5" && prev.kernel.isHardened;
      maintainers = with maintainers; [
        deinferno
        vifino
      ];
    };
  };

  # kitty = prev.kitty.overrideAttrs (oldAttrs: {
  #   patches =
  #     (oldAttrs.patches or [])
  #     ++ [
  #       ./patch/kitty-patch/fix_wl_platform_toplevel.patch
  #       ./patch/kitty-patch/fix_xdg_toplevel_switch.patch
  #     ];
  # });
}
