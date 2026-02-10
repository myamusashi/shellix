final: prev: {
  upower = prev.upower.overrideAttrs (oldAttrs: {
    doCheck = false;
  });

  libvdpau-va-gl = prev.libvdpau-va-gl.overrideAttrs (oldAttrs: {
    cmakeFlags = [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    ];
  });

  # Make vesktop running natively on wayland
  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    desktopItem =
      oldAttrs.desktopItem
      // {
        exec = "${oldAttrs.desktopItem.exec} --enable-features=UseOzonePlatform --ozone-platform=wayland";
      };
  });

  vmware-workstation = prev.vmware-workstation.overrideAttrs (oldAttrs: {
    installPhase = ''
      ${oldAttrs.installPhase}

      mv $out/bin/vmware $out/bin/vmware-bin

      makeWrapper $out/bin/vmware-bin $out/bin/vmware \
        --set GTK_THEME "Adwaita-dark"

      if [ -f $out/share/applications/vmware-workstation.desktop ]; then
        substituteInPlace $out/share/applications/vmware-workstation.desktop \
          --replace "Exec=@@BINARY@@" "Exec=$out/bin/vmware"

        substituteInPlace $out/share/applications/vmware-player.desktop \
          --replace "Exec=@@BINARY@@" "Exec=$out/bin/vmware"
      fi
    '';
  });

  ## Hotfix
  python3Packages = prev.python3Packages.overrideScope (self: super: {
    tree-sitter-rust = super.tree-sitter-rust.overrideAttrs (oldAttrs: rec {
      version = "0.23.2";

      src = final.fetchFromGitHub {
        owner = "tree-sitter";
        repo = "tree-sitter-rust";
        tag = "v${version}";
        hash = "sha256-aT+tlrEKMgWqTEq/NHh8Vj92h6i1aU6uPikDyaP2vfc=";
      };
    });

    doCheck = false;

    textual = super.textual.overrideAttrs (oldAttrs: {
      disabledTestPaths = [
        "tests/snapshot_tests/test_snapshots.py"
        "tests/test_widget.py"
        "tests/text_area/test_languages.py"
        "tests/text_area/test_setting_themes.py"
      ];

      doCheck = false;
    });
  });
  ## End

  ## Fix outdated packages
  material-symbols = prev.material-symbols.overrideAttrs (oldAttrs: {
    version = "4.0.0-unstable-2025-09-19";

    src = final.fetchFromGitHub {
      owner = "google";
      repo = "material-design-icons";
      rev = "bb04090f930e272697f2a1f0d7b352d92dfeee43";
      hash = "sha256-5bcEh7Oetd2JmFEPCcoweDrLGQTpcuaCU8hCjz8ls3M=";
      sparseCheckout = ["variablefont"];
    };
  });

  ## Fix vmware failed buildPhase
  linuxPackages_cachyos = prev.linuxPackages_cachyos.extend (self: super: {
    vmware = super.vmware.overrideAttrs (oldAttrs: {
      version = "workstation-17.6.3-20250728-${self.kernel.version}";
      src = final.fetchFromGitHub {
        owner = "philipl";
        repo = "vmware-host-modules";
        rev = "6797e552638a28d1fa1e9ebd7ab5d3c628671ba0";
        hash = "sha256-KCLxAF6UtNIdKcDoANviln2RJuz1Ld8jq5QFW9ONghs=";
      };
      nativeBuildInputs =
        (oldAttrs.nativeBuildInputs or [])
        ++ [
          final.clang_21
          final.llvm_21
          final.llvmPackages_21.bintools
        ];
      makeFlags =
        (oldAttrs.makeFlags or [])
        ++ [
          "CC=${final.clang_21}/bin/clang"
          "HOSTCC=${final.clang_21}/bin/clang"
          "LLVM=1"
        ];
      NIX_CFLAGS_COMPILE = toString [
        "-Wno-error=implicit-function-declaration"
        "-Wno-error=implicit-int"
        "-Wno-error=deprecated-declarations"
        "-Wno-error=format-security"
        "-Wno-unused-command-line-argument"
      ];
      preBuild =
        (oldAttrs.preBuild or "")
        + ''
          export CC=${final.clang_21}/bin/clang
          export HOSTCC=${final.clang_21}/bin/clang
          export LLVM=1
          export KCFLAGS="$NIX_CFLAGS_COMPILE"

          # Ensure clang is in PATH and override any gcc references
          export PATH="${final.clang_21}/bin:$PATH"

          # Some kernel build systems check for gcc specifically, create a symlink
          mkdir -p $TMPDIR/bin
          ln -sf ${final.clang_21}/bin/clang $TMPDIR/bin/gcc
          ln -sf ${final.clang_21}/bin/clang++ $TMPDIR/bin/g++
          export PATH="$TMPDIR/bin:$PATH"
        '';
    });
  });

  linuxPackages_cachyos-lto = prev.linuxPackages_cachyos-lto.extend (self: super: {
    vmware = super.vmware.overrideAttrs (oldAttrs: {
      version = "workstation-17.6.3-20250728-${self.kernel.version}";
      src = final.fetchFromGitHub {
        owner = "philipl";
        repo = "vmware-host-modules";
        rev = "6797e552638a28d1fa1e9ebd7ab5d3c628671ba0";
        hash = "sha256-KCLxAF6UtNIdKcDoANviln2RJuz1Ld8jq5QFW9ONghs=";
      };
      nativeBuildInputs =
        (oldAttrs.nativeBuildInputs or [])
        ++ [
          final.clang_21
          final.llvm_21
          final.llvmPackages_21.bintools
        ];
      makeFlags =
        (oldAttrs.makeFlags or [])
        ++ [
          "CC=${final.clang_21}/bin/clang"
          "HOSTCC=${final.clang_21}/bin/clang"
          "LLVM=1"
        ];
      NIX_CFLAGS_COMPILE = toString [
        "-Wno-error=implicit-function-declaration"
        "-Wno-error=implicit-int"
        "-Wno-error=deprecated-declarations"
        "-Wno-error=format-security"
        "-Wno-unused-command-line-argument"
      ];
      preBuild =
        (oldAttrs.preBuild or "")
        + ''
          export CC=${final.clang_21}/bin/clang
          export HOSTCC=${final.clang_21}/bin/clang
          export LLVM=1
          export KCFLAGS="$NIX_CFLAGS_COMPILE"

          # Ensure clang is in PATH and override any gcc references
          export PATH="${final.clang_21}/bin:$PATH"

          # Some kernel build systems check for gcc specifically, create a symlink
          mkdir -p $TMPDIR/bin
          ln -sf ${final.clang_21}/bin/clang $TMPDIR/bin/gcc
          ln -sf ${final.clang_20}/bin/clang++ $TMPDIR/bin/g++
          export PATH="$TMPDIR/bin:$PATH"
        '';
    });
  });
}
