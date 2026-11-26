final: prev: {
    upower = prev.upower.overrideAttrs {
        doCheck = false;
    };

    antigravity-cli = prev.antigravity-cli.overrideAttrs (oldAttrs: let
        version = "1.5.12";
        buildId = "5281398513336320";
    in {
        inherit version;

        src = prev.fetchurl {
            url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${version}-${buildId}/linux-x64/cli_linux_x64.tar.gz";
            hash = "sha256-Dwy4Uc3J++3VBDJXCqaunEw5i56j8eI+d3b3B2Q8Wz4=";
        };

        passthru =
            (oldAttrs.passthru or {})
            // {
                wholeVersion = "${version}-${buildId}";
            };
    });

    mprisence = prev.mprisence.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [final.aws-lc];
    });

    firecracker = prev.firecracker.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.pkg-config];
        buildInputs = (oldAttrs.buildInputs or []) ++ [final.aws-lc];
    });

    fastfetch-unwrapped = prev.fastfetch-unwrapped.overrideAttrs rec {
        version = "2.69.0";

        src = final.fetchFromGitHub {
            owner = "fastfetch-cli";
            repo = "fastfetch";
            tag = version;
            hash = "sha256-osfQZEP6t3TdwlO+0agD8fU2z1UECJWLF+WPovwEk64=";
        };
    };

    stylua = prev.stylua.overrideAttrs rec {
        version = "2.5.2";

        src = final.fetchFromGitHub {
            owner = "johnnymorganz";
            repo = "stylua";
            rev = "v${version}";
            hash = "sha256-C0X7IdYqs/hhSX96XWVyk7rfQNd9DjYxYgHL34cI+3g=";
        };

        cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            hash = "sha256-m31oocBkx4i2KxM0YC1omVWtypFi7iEoDVlXgT93iSI=";
        };
    };

    luaformatter = prev.luaformatter.overrideAttrs {
        version = "unstable-21-02-2023";

        src = final.fetchFromGitHub {
            owner = "Koihik";
            repo = "LuaFormatter";
            rev = "29afe1046ad015de96ffdb6d361a21882356e801";
            hash = "sha256-6f2UM1F9va08gkkePur8EF23bL5Dk29VXrumLWajh2c=";
        };

        patches = [
            (final.replaceVars ../patches/luaformatter-fix-lib-paths.patch {
                antlr4RuntimeCppDev = final.antlr4_9.runtime.cpp.dev;
                antlr4RuntimeCpp = final.antlr4_9.runtime.cpp;
                yamlCppDev = final.yaml-cpp;
                yamlCpp = final.yaml-cpp;
                inherit (final) libargs catch2;
            })
        ];
    };

    tree-sitter-bundled-vendor = prev.tree-sitter-bundled-vendor.override {
        vendorHash = "sha256-ie+/48dVU3r+tx/sQBWRIZEWSNWwMBANCqQLnv96JXs=";
    };

    python313Packages = prev.python313Packages.overrideScope (_: pythonPrev: {
        gradio-client = pythonPrev.gradio-client.overridePythonAttrs {
            dontCheckPythonMetadata = true;
        };

        gradio = pythonPrev.gradio.overridePythonAttrs {
            dontCheckPythonMetadata = true;
            dontCheckRuntimeDeps = true;
        };

        gradio-client-sans-reverse-dependencies = pythonPrev.gradio-client-sans-reverse-dependencies.overrideAttrs {
            pythonMetadataCheckPhase = true;
        };

        hf-gradio = pythonPrev.hf-gradio.overrideAttrs {
            pythonMetadataCheckPhase = true;
        };
    });

    python3Packages = prev.python3Packages.overrideScope (_: pythonPrev: {
        textual = pythonPrev.textual.overrideAttrs (oldAttrs: {
            meta = oldAttrs.meta // {broken = false;};
            disabledTestPaths = [
                "tests/snapshot_tests/test_snapshots.py"
                "tests/test_widget.py"
                "tests/text_area/test_languages.py"
                "tests/text_area/test_setting_themes.py"
            ];
        });
    });

    libvdpau-va-gl = prev.libvdpau-va-gl.overrideAttrs {
        cmakeFlags = ["-DCMAKE_POLICY_VERSION_MINIMUM=3.5"];
    };

    grpc-tools = prev.grpc-tools.overrideAttrs {
        cmakeFlags = ["-DCMAKE_POLICY_VERSION_MINIMUM=3.5"];
    };

    cmark-gfm = prev.cmark-gfm.overrideAttrs {
        cmakeFlags = ["-DCMAKE_POLICY_VERSION_MINIMUM=3.5"];
    };

    allegro = prev.allegro.overrideAttrs (oldAttrs: {
        cmakeFlags =
            (oldAttrs.cmakeFlags or [])
            ++ [
                "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
            ];
    });
}
