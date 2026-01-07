{
  lib,
  gcc,
  fetchFromGitHub,
  stdenvNoCC,
  pkg-config,
  bash,
  gtk3,
  cmake,
  gtkmm3,
}:
stdenvNoCC.mkDerivation rec {
  pname = "customfetch";
  version = "2.0.0-beta1";

  src = fetchFromGitHub {
    owner = "Toni500github";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RgTEhoDMe0qoH+0fB0j+VJ7NIdrs1fHMOPHAJmv2O3s=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    gcc
  ];

  buildInputs = [
    gtk3
    gtkmm3
  ];

  postPatch = ''
    substituteInPlace scripts/make_mo.sh \
        --replace-fail "#!/bin/bash" \
          "#! ${bash}/bin/bash -e"
  '';

  meta = with lib; {
    description = "A modular information fetching (neofetch-like) tool, which its focus point is the performance and customizability. Android widget migrated to https://github.com/Toni500github/customfetch-android-app";
    homepage = "https://github.com/Toni500github/customfetch";
    license = licenses.bsd3;
    maintainers = [myamusashi];
  };
}
