{
    lib,
    fetchFromGitHub,
    go_1_27,
    buildGoModule,
}: let
    bgm = buildGoModule.override {
        go = go_1_27;
    };
in
    bgm (finalAttrs: {
        pname = "zcode-bridge";
        version = "0.1.0";

        src = fetchFromGitHub {
            owner = "azrinaldi";
            repo = "zcode-bridge";
            tag = "v${finalAttrs.version}";
            hash = "sha256-1cl3kzs555cvu4gHEj1tSAzaV7fH3/majxXvI+IfzUo=";
        };

        vendorHash = null;
        subPackages = ["cmd/zcode-bridge"];
        ldflags = ["-s" "-w"];

        meta = with lib; {
            description = "OpenAI- and Anthropic-compatible local gateway for ZCode plan quota";
            homepage = "https://github.com/azrinaldi/zcode-bridge";
            license = licenses.mit;
            mainProgram = "zcode-bridge";
            maintainers = [];
            platforms = platforms.unix;
        };
    })
