# Hotfixes for broken or outdated packages
final: prev: {
    upower = prev.upower.overrideAttrs (oldAttrs: {
        doCheck = false;
    });

    luaformatter = prev.luaformatter.overrideAttrs (oldAttrs: {
        version = "unstable-21-02-2023";

        src = final.fetchFromGitHub {
            owner = "Koihik";
            repo = "LuaFormatter";
            rev = "29afe1046ad015de96ffdb6d361a21882356e801";
            hash = "sha256-6f2UM1F9va08gkkePur8EF23bL5Dk29VXrumLWajh2c=";
        };

        patches = [
            (final.replaceVars ./patch/luaformatter/fix-lib-paths.patch {
                antlr4RuntimeCppDev = final.antlr4_9.runtime.cpp.dev;
                antlr4RuntimeCpp = final.antlr4_9.runtime.cpp;
                yamlCppDev = final.yaml-cpp;
                yamlCpp = final.yaml-cpp;
                inherit (final) libargs catch2;
            })
        ];
    });

    # Fix tree-sitter-bundled-vendor hash
    tree-sitter-bundled-vendor = prev.tree-sitter-bundled-vendor.override (oldAttrs: {
        vendorHash = "sha256-ie+/48dVU3r+tx/sQBWRIZEWSNWwMBANCqQLnv96JXs=";
    });

    wl-screenrec = prev.wl-screenrec.overrideAttrs (oldAttrs: rec {
        version = "unstable-1-12-25";

        src = final.fetchFromGitHub {
            owner = "russelltg";
            repo = "wl-screenrec";
            rev = "43565c1a5f124ed97df578b5b2b5f63a4b531056";
            hash = "sha256-nDdZ1zudbIGPZU7wFNCrrHmjwhTDwJKs9d8IgyaeAAw=";
        };

        cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            hash = "sha256-vIVDlEKOeAnvaJj+ov25HTbXf26RMFf0K3Tca/hONS8=";
        };

        cargoBuildFlags = ["--all-features"];

        buildInputs =
            (final.lib.remove final.ffmpeg_6 oldAttrs.buildInputs)
            ++ [
                final.ffmpeg-full
                final.vulkan-loader
                final.vulkan-headers
            ];

        nativeBuildInputs =
            (oldAttrs.nativeBuildInputs or [])
            ++ [
                final.makeWrapper
            ];
    });

    tree-sitter = prev.tree-sitter.overrideAttrs (oldAttrs: rec {
        version = "0.26.5";

        src = final.fetchFromGitHub {
            owner = "tree-sitter";
            repo = "tree-sitter";
            tag = "v${version}";
            hash = "sha256-tnZ8VllRRYPL8UhNmrda7IjKSeFmmOnW/2/VqgJFLgU=";
            fetchSubmodules = true;
        };

        patches = [
            ./patch/tree-sitter-patch/remove-web-interface.patch
        ];

        cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit src;
            hash = "sha256-EU8kdG2NT3NvrZ1AqvaJPLpDQQwUhYG3Gj5TAjPYRsY=";
        };

        nativeBuildInputs =
            (oldAttrs.nativeBuildInputs or [])
            ++ [final.rustPlatform.bindgenHook];
    });

    python3Packages = prev.python3Packages.overrideScope (self: super: {
        tree-sitter = super.tree-sitter.overrideAttrs (oldAttrs: rec {
            version = "0.25.2";

            src = final.fetchFromGitHub {
                owner = "tree-sitter";
                repo = "py-tree-sitter";
                tag = "v${version}";
                hash = "sha256-ZDt/8suteaAjGdk71l8eej7jDkkVpVDBIZS63SA8tsU=";
                fetchSubmodules = true;
            };

            doCheck = false;
            doInstallCheck = false;

            meta = {
                description = "Python bindings to the Tree-sitter parsing library";
                homepage = "https://github.com/tree-sitter/py-tree-sitter";
                changelog = "https://github.com/tree-sitter/py-tree-sitter/releases/tag/${src.tag}";
                license = final.lib.licenses.mit;
                maintainers = [final.lib.maintainers.fab];
            };
        });

        tree-sitter-rust = super.tree-sitter-rust.overrideAttrs (oldAttrs: rec {
            version = "0.24.0";

            src = final.fetchFromGitHub {
                owner = "tree-sitter";
                repo = "tree-sitter-rust";
                tag = "v${version}";
                hash = "sha256-aT+tlrEKMgWqTEq/NHh8Vj92h6i1aU6uPikDyaP2vfc=";
            };
        });

        textual = super.textual.overrideAttrs (oldAttrs: {
            meta = oldAttrs.meta // {broken = false;};
            disabledTestPaths = [
                "tests/snapshot_tests/test_snapshots.py"
                "tests/test_widget.py"
                "tests/text_area/test_languages.py"
                "tests/text_area/test_setting_themes.py"
            ];
        });
    });

    # Fix cmake policy
    libvdpau-va-gl = prev.libvdpau-va-gl.overrideAttrs (oldAttrs: {
        cmakeFlags = ["-DCMAKE_POLICY_VERSION_MINIMUM=3.5"];
    });

    grpc-tools = prev.grpc-tools.overrideAttrs (oldAttrs: {
        cmakeFlags = ["-DCMAKE_POLICY_VERSION_MINIMUM=3.5"];
    });

    cmark-gfm = prev.cmark-gfm.overrideAttrs (oldAttrs: {
        cmakeFlags = ["-DCMAKE_POLICY_VERSION_MINIMUM=3.5"];
    });

    allegro = prev.allegro.overrideAttrs (oldAttrs: {
        cmakeFlags =
            (oldAttrs.cmakeFlags or [])
            ++ [
                "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
            ];
    });
}
