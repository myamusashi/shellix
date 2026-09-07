{pkgs, ...}: {
    sine-engine = pkgs.fetchzip {
        url = "https://github.com/CosmoCreeper/Sine/releases/download/v2.3.3/engine.zip";
        hash = "sha256-Gut2xrBNyrG1oBhNzlsmZpQsP4ithXOInM2Z6UUI4bo=";
    };

    sine-profile = pkgs.fetchzip {
        url = "https://github.com/sineorg/bootloader/releases/download/v0.1.4/profile.zip";
        hash = "sha256-/OkDU1Z/jC9AtMnUctU145serLOpr0D5tfCL5uo16tQ=";
    };

    sine-program = pkgs.fetchzip {
        url = "https://github.com/sineorg/bootloader/releases/download/v0.1.4/program.zip";
        hash = "sha256-6suI8iRxQr6L6uVIcs2WOWUjf6O5XipqjrHHGlKzQZc=";
        stripRoot = false;
    };

    arc20-src = pkgs.fetchFromGitHub {
        owner = "YashjitPal";
        repo = "Arc-2.0";
        rev = "88e08ae65c22d9ec92f5c995284c1181ffd7abaa";
        sha256 = "sha256-FM6lWtN1HJ7QbNvO4BbkdhpdwTb8ecH7R5qtw4q7bLI=";
    };

    superPins-src =
        pkgs.fetchFromGitHub {
            owner = "CosmoCreeper";
            repo = "Zen-Themes";
            rev = "88639a2587d076925baa33d4af3c867499da526e";
            sha256 = "sha256-Xb2C9dWArdJqNAkXFYfvrxGKglnTrqSUF8qnK5nUneE=";
        }
        + "/SuperPins";

    newtabicon-src = pkgs.fetchFromGitHub {
        owner = "thestrike72";
        repo = "zen-browser-add-new-tab-icon-to-urlbar";
        rev = "8aef00b1e14011d389b70c26ffc1553b3a75461a";
        sha256 = "sha256-SRpNYIAAH1NHxqkylBSb54C6XVRq3SxyNs6WkC8QhRw=";
    };

    kaedriz-src = pkgs.fetchFromGitHub {
        owner = "Kaedriz";
        repo = "ZenMods";
        rev = "36ec0d0e99bff70c04764de92888e017853de3e8";
        sha256 = "sha256-uZb2XVKyEtfsllR4DBDKgRlWBvvamlPpViMCrh2FjZM=";
    };

    psu-mods-src = pkgs.fetchFromGitHub {
        owner = "psu";
        repo = "zen-mods";
        rev = "8a3505a98e37db57b51a11f19e18695f9e417bb0";
        sha256 = "sha256-LwKxT62wSb0wMdZz7Oh0LuXG/2zE8ztdJRD0SZcltLk=";
    };

    findbar-src = pkgs.fetchFromGitHub {
        owner = "RobotoSkunk";
        repo = "ff-better-findbar";
        rev = "e4781eca01ac4e84a1c3f452bd74d99eac889cec";
        sha256 = "sha256-Kgspv819xbo4jMvJ5Rg8JGKqjigfCAEnbCJYPhdzlMQ=";
    };

    customize-fonts-src = pkgs.fetchFromGitHub {
        owner = "joadr";
        repo = "zen-customize-fonts-size";
        rev = "3eb471318f70af4a66b37e38ea4bdf7275ce760e";
        sha256 = "sha256-ZmF4zgi1GKkQC6kfCUw7kBEbFyYxrgPhU6wuCi9LUxU=";
    };

    fury7425-src = pkgs.fetchFromGitHub {
        owner = "Fury7425";
        repo = "my-zen-mods";
        rev = "01e512b08661a17b0e320578f37c67abd211c4c1";
        sha256 = "sha256-lr2P0WXtVr0hbsP3SesECBni1jC1DaRHbTrs4OzsSvQ=";
    };

    tobinio-src = pkgs.fetchFromGitHub {
        owner = "ToBinio";
        repo = "zen-mods";
        rev = "ebc6056a0add63b916ca588d739f9902e6764a35";
        sha256 = "sha256-0VJnOhXUUQmYE0iCzoQ5uh8kjdaWv4AZgr2Kqwe685s=";
    };
}
