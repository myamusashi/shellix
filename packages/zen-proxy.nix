{
    lib,
    fetchFromGitHub,
    stdenvNoCC,
    bun,
    nodejs,
    makeWrapper,
}:
stdenvNoCC.mkDerivation {
    pname = "zen-proxy";
    version = "1.0.0";

    src = fetchFromGitHub {
        owner = "12errh";
        repo = "zen-proxy";
        rev = "24389490c8abb8611158a1a969c3968473e170e2";
        hash = "sha256-AS/9DXy/z7TGvnSwIIBfURzwAOWkN5BAXUlrEjPyQmQ=";
    };

    nativeBuildInputs = [makeWrapper nodejs];

    patches = [
        ../patches/new-opencode-model.patch
    ];

    doCheck = false;

    installPhase = ''
        runHook preInstall

        appDir="$out/lib/zen-proxy"
        mkdir -p "$appDir"

        install -Dm644 zen-proxy.mjs "$appDir/zen-proxy.mjs"
        install -Dm644 models.json "$appDir/models.json"
        install -Dm644 agent-preamble.txt "$appDir/agent-preamble.txt"
        install -Dm644 agent-tools.json "$appDir/agent-tools.json"
        install -Dm644 LICENSE "$appDir/LICENSE"
        cp -r public assets "$appDir/"

        makeWrapper ${bun}/bin/bun "$out/bin/zen-proxy" \
            --add-flags "$appDir/zen-proxy.mjs" \
            --run 'export ZEN_PROXY_CONFIG="''${ZEN_PROXY_CONFIG:-''${XDG_CONFIG_HOME:-$HOME/.config}/zen-proxy/zen-proxy.json}"' \
            --run 'mkdir -p "$(dirname "$ZEN_PROXY_CONFIG")"'

        runHook postInstall
    '';

    meta = {
        description = "OpenCode Zen model proxy for coding agents";
        homepage = "https://github.com/12errh/zen-proxy";
        license = lib.licenses.mit;
        mainProgram = "zen-proxy";
        platforms = lib.platforms.unix;
    };
}
