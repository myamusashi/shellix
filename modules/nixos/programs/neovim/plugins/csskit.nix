{
    lib,
    rustPlatform,
    pkg-config,
    openssl,
    fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
    pname = "csskit";
    version = "0.0.25";

    src = fetchFromGitHub {
        owner = "csskit";
        repo = "csskit";
        rev = "v${version}";
        hash = "sha256-BiBXrbbhKfrTua7xLtnqYBL2CCu6i7PTRo1KYHrOk7w=";
    };

    cargoHash = "sha256-1SdBPWJ5avLCJfkItbgbSJ9XGDsjRMFJO16vPKWuZ4o=";

    nativeBuildInputs = [pkg-config];
    buildInputs = [openssl];

    cargoBuildFlags = ["--package" "csskit"];
    cargoTestFlags = ["--package" "csskit"];

    meta = with lib; {
        description = "Refreshing CSS!";
        homepage = "https://csskit.rs";
        license = licenses.mit;
        mainProgram = "csskit";
        maintainers = [];
    };
}
