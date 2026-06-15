{pkgs, ...}: rec {
  electronFlags = [
    "--enable-features=Vulkan,VaapiVideoDecodeLinuxGL,VaapiIgnoreDriverChecks,VaapiVideoDecoder,VaapiVideoEncoder,AcceleratedVideoEncoder,UseMultiPlaneFormatForHardwareVideo,SkiaGraphite"
    "--ignore-gpu-blocklist"
    "--enable-zero-copy"
  ];

  wrapElectron = pkg: binary:
    pkgs.symlinkJoin {
      name = "${pkg.pname or pkg.name}-wrapped";
      paths = [
        (pkgs.writeShellScriptBin binary ''
          exec ${pkg}/bin/${binary} ${builtins.concatStringsSep " " electronFlags} "$@"
        '')
        pkg
      ];
    };

  wrapWithEnv = pkg: binary: env:
    let
      exports = builtins.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (k: v: "export ${k}=\"${v}\"") env);
    in
    pkgs.symlinkJoin {
      name = "${pkg.pname or pkg.name}-wrapped";
      paths = [
        (pkgs.writeShellScriptBin binary ''
          ${exports}
          exec ${pkg}/bin/${binary} "$@"
        '')
        pkg
      ];
    };
}
