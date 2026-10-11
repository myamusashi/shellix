# Hotfixes for broken or outdated packages
final: prev: {
    upower = prev.upower.overrideAttrs (oldAttrs: {
        doCheck = false;
    });

    fastfetch-unwrapped = prev.fastfetch-unwrapped.overrideAttrs (oldAttrs: rec {
        version = "2.69.0";

        src = final.fetchFromGitHub {
            owner = "fastfetch-cli";
            repo = "fastfetch";
            tag = version;
            hash = "sha256-osfQZEP6t3TdwlO+0agD8fU2z1UECJWLF+WPovwEk64=";
        };
    });

    stylua = prev.stylua.overrideAttrs (oldAttrs: rec {
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

    python313Packages = prev.python313Packages.overrideScope (pyFinal: pyPrev: {
        gradio-client = pyPrev.gradio-client.overridePythonAttrs (old: {
            dontCheckPythonMetadata = true;
        });

        gradio = pyPrev.gradio.overridePythonAttrs (old: {
            dontCheckPythonMetadata = true;
            dontCheckRuntimeDeps = true;
        });

        gradio-client-sans-reverse-dependencies = pyPrev.gradio-client-sans-reverse-dependencies.overrideAttrs (old: {
            pythonMetadataCheckPhase = true;
        });

        hf-gradio = pyPrev.hf-gradio.overrideAttrs (old: {
            pythonMetadataCheckPhase = true;
        });
    });

    python3Packages = prev.python3Packages.overrideScope (self: super: {
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
