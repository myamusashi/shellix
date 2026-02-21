self: super: {
    tree-sitter-bundled-vendor = super.tree-sitter-bundled-vendor.override (oldAttrs: {
        vendorHash = "sha256-ie+/48dVU3r+tx/sQBWRIZEWSNWwMBANCqQLnv96JXs=";
    });
}
