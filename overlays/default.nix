final: prev: {
  upower = prev.upower.overrideAttrs (oldAttrs: {
    doCheck = false;
  });

  vmware-workstation = prev.vmware-workstation.overrideAttrs (oldAttrs: {
    installPhase = ''
      # Jalankan install phase orisinal terlebih dahulu
      ${oldAttrs.installPhase}

      # Ganti nama binary asli
      mv $out/bin/vmware $out/bin/vmware-bin

      # Buat wrapper script yang mengatur GTK_THEME sebelum menjalankan binary asli
      makeWrapper $out/bin/vmware-bin $out/bin/vmware \
        --set GTK_THEME "Adwaita-dark"

      # Perbarui file .desktop agar menunjuk ke wrapper script
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
    tree-sitter = super.tree-sitter.overrideAttrs (oldAttrs: rec {
      version = "0.24.0";

      src = final.fetchFromGitHub {
        owner = "tree-sitter";
        repo = "py-tree-sitter";
        tag = "v${version}";
        hash = "sha256-ZDt/8suteaAjGdk71l8eej7jDkkVpVDBIZS63SA8tsU=";
        fetchSubmodules = true;
      };

      meta = {
        description = "Python bindings to the Tree-sitter parsing library";
        homepage = "https://github.com/tree-sitter/py-tree-sitter";
        changelog = "https://github.com/tree-sitter/py-tree-sitter/releases/tag/${src.tag}";
        license = final.lib.licenses.mit;
        maintainers = [final.lib.maintainers.fab];
      };
    });

    tree-sitter-rust = super.tree-sitter-rust.overrideAttrs (oldAttrs: rec {
      version = "0.23.2";

      src = final.fetchFromGitHub {
        owner = "tree-sitter";
        repo = "tree-sitter-rust";
        tag = "v${version}";
        hash = "sha256-aT+tlrEKMgWqTEq/NHh8Vj92h6i1aU6uPikDyaP2vfc=";
      };
    });

    textual = super.textual.overrideAttrs (oldAttrs: {
      meta = oldAttrs.meta // {broken = false;};
    });
  });
  ##

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

  linuxPackages_cachyos-lto = prev.linuxPackages_cachyos-lto.extend (self: super: {
    vmware = super.vmware.overrideAttrs (oldAttrs: {
      version = "workstation-17.6.3-20250608-${self.kernel.version}";

      src = final.fetchFromGitHub {
        owner = "philipl";
        repo = "vmware-host-modules";
        rev = "e08764f84df3bd14407291e02346b7c5c54d0bf6";
        hash = "sha256-RDVKropC+VOv1uJijOGlLt6iqZI8Cm9aWlbmvZj2CSk=";
      };

      nativeBuildInputs =
        (oldAttrs.nativeBuildInputs or [])
        ++ [
          final.clang_20
          final.llvm_20
        ];

      makeFlags =
        (oldAttrs.makeFlags or [])
        ++ [
          "CC=${final.clang_20}/bin/clang"
          "HOSTCC=${final.clang_20}/bin/clang"
        ];

      NIX_CFLAGS_COMPILE = toString [
        "-Wno-error=implicit-function-declaration"
        "-Wno-error=implicit-int"
        "-Wno-error=deprecated-declarations"
        "-Wno-error=format-security"
      ];

      preBuild =
        (oldAttrs.preBuild or "")
        + ''
          export CC=${final.clang_20}/bin/clang
          export HOSTCC=${final.clang_20}/bin/clang
          export LLVM=1
          export KCFLAGS="$KCFLAGS -Wno-unused-command-line-argument"
        '';
    });
  });

  # kitty = prev.kitty.overrideAttrs (oldAttrs: {
  #   patches =
  #     (oldAttrs.patches or [])
  #     ++ [
  #       ./patch/kitty-patch/fix_wl_platform_toplevel.patch
  #       ./patch/kitty-patch/fix_xdg_toplevel_switch.patch
  #     ];
  # });
}
