# Hotfixes for broken or outdated packages
final: prev: {
  upower = prev.upower.overrideAttrs (oldAttrs: {
    doCheck = false;
  });

  # Fix tree-sitter-bundled-vendor hash (for stable pkgs)
  tree-sitter-bundled-vendor = prev.tree-sitter-bundled-vendor.override (oldAttrs: {
    vendorHash = "sha256-ie+/48dVU3r+tx/sQBWRIZEWSNWwMBANCqQLnv96JXs=";
  });

  # tree-sitter = prev.tree-sitter.override (oldAttrs: rec {
  #   version = "0.26.5";
  #
  #   src = final.fetchFromGitHub {
  #     owner = "tree-sitter";
  #     repo = "tree-sitter";
  #     tag = "v${version}";
  #     hash = "sha256-tnZ8VllRRYPL8UhNmrda7IjKSeFmmOnW/2/VqgJFLgU=";
  #     fetchSubmodules = true;
  #   };
  #
  #   patches = [
  #     ./patch/tree-sitter-patch/remove-web-interface.patch
  #   ];
  #
  #   cargoHash = "";
  #
  #   nativeBuildInputs =
  #     (oldAttrs.nativeBuildInputs or [])
  #     ++ [
  #       final.rustPlatform.bindgenHook
  #     ];
  # });

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

  vicinae = prev.vicinae.overrideAttrs (oldAttrs: {
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
