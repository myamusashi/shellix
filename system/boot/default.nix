{
  pkgs,
  lib,
  ...
}: {
  boot = {
    # Need when i want to use vmware
    # kernelPackages = pkgs.linuxPackages_xanmod_stable;
    kernelPackages = pkgs.linuxPackages_cachyos-lto.extend (self: super: {
      vmware = super.vmware.overrideAttrs (oldAttrs: {
        version = "workstation-17.6.3-20250608-${self.kernel.version}";
        src = pkgs.fetchFromGitHub {
          owner = "philipl";
          repo = "vmware-host-modules";
          rev = "e08764f84df3bd14407291e02346b7c5c54d0bf6";
          hash = "sha256-RDVKropC+VOv1uJijOGlLt6iqZI8Cm9aWlbmvZj2CSk=";
        };

        # Add build dependencies including clang
        nativeBuildInputs =
          (oldAttrs.nativeBuildInputs or [])
          ++ [
            pkgs.clang_20
            pkgs.llvm_20
          ];

        # Force the build to use clang instead of gcc
        makeFlags =
          (oldAttrs.makeFlags or [])
          ++ [
            "CC=${pkgs.clang_20}/bin/clang"
            "HOSTCC=${pkgs.clang_20}/bin/clang"
          ];

        # Set environment variables for the build
        NIX_CFLAGS_COMPILE = toString [
          "-Wno-error=implicit-function-declaration"
          "-Wno-error=implicit-int"
          "-Wno-error=deprecated-declarations"
          "-Wno-error=format-security"
        ];

        # Ensure the kernel build system uses clang
        preBuild =
          (oldAttrs.preBuild or "")
          + ''
            export CC=${pkgs.clang_20}/bin/clang
            export HOSTCC=${pkgs.clang_20}/bin/clang
            export LLVM=1
            export KCFLAGS="$KCFLAGS -Wno-unused-command-line-argument"
          '';
      });
    });
    initrd.verbose = false;
    consoleLogLevel = 0;
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usbhid"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    plymouth = {
      enable = true;
      theme = "cross_hud";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = ["cross_hud"];
        })
      ];
    };

    supportedFilesystems = ["ntfs"];
    kernelModules = [
      "kvm-intel"
      "uas"
      "usbhid"
      "hid"
      "usb_storage"
      "zram"
    ];
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "boot.shell_on_fail"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "console=tty1"
      "noibrs"
      "noibpb"
      "nopti"
      "nospectre_v2"
      "nospectre_v1"
      "l1tf=off"
      "nospec_store_bypass_disable"
      "no_stf_barrier"
      "mds=off"
      "mitigations=off"
    ];

    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.core.somaxconn" = 1024;
      "net.core.netdev_max_backlog" = 5000;

      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 87380 16777216";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_window_scaling" = 1;
      "net.ipv4.tcp_keepalive_time" = 60;
      "net.ipv4.tcp_keepalive_intvl" = 10;
      "net.ipv4.tcp_keepalive_probes" = 6;

      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_ratio" = 10;
      "vm.swappiness" = 15;
    };
  };
}
