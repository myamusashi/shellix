final: prev: {
    vmware-workstation = prev.vmware-workstation.overrideAttrs (oldAttrs: {
        installPhase = ''
            ${oldAttrs.installPhase}

            mv $out/bin/vmware $out/bin/vmware-bin

            makeWrapper $out/bin/vmware-bin $out/bin/vmware \
                --set GTK_THEME "Adwaita-dark" \
                --set FONTCONFIG_FILE "${final.fontconfig.out}/etc/fonts/fonts.conf" \
                --set FONTCONFIG_PATH "${final.fontconfig.out}/etc/fonts"

            if [ -f $out/share/applications/vmware-workstation.desktop ]; then
              substituteInPlace $out/share/applications/vmware-workstation.desktop \
                --replace "Exec=@@BINARY@@" "Exec=$out/bin/vmware"

              substituteInPlace $out/share/applications/vmware-player.desktop \
                --replace "Exec=@@BINARY@@" "Exec=$out/bin/vmware"
            fi
        '';
    });

    #### [DEPRECATED] not using kernel from chaotic again
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

                    export PATH="${final.clang_21}/bin:$PATH"

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

                    export PATH="${final.clang_21}/bin:$PATH"

                    mkdir -p $TMPDIR/bin
                    ln -sf ${final.clang_21}/bin/clang $TMPDIR/bin/gcc
                    ln -sf ${final.clang_21}/bin/clang++ $TMPDIR/bin/g++
                    export PATH="$TMPDIR/bin:$PATH"
                '';
        });
    });
    #### [DEPRECATED]
}
