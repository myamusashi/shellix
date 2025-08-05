{pkgs, ...}: {
  official-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "main";
    hash = "sha256-29K8PmBoqAMcQhDIfOVnbJt2FU4BR6k23Es9CqyEloo=";
  };

  mediainfo = pkgs.fetchFromGitHub {
    owner = "boydaihungst";
    repo = "mediainfo.yazi";
    rev = "master";
    hash = "sha256-CTynpmB101ylCiHKbwX5nVrt5OMhgAu48GVxXsNqd9s=";
  };

  office = pkgs.fetchFromGitHub {
    owner = "macydnah";
    repo = "office.yazi";
    rev = "main";
    hash = "sha256-XE+EfVPsO09zG8qYEhN6O95mS9NJlTdOd4Gsem2KtPI=";
  };

  eza-preview = pkgs.fetchFromGitHub {
    owner = "ahkohd";
    repo = "eza-preview.yazi";
    rev = "main";
    hash = "sha256-Q8RwpzUkZkz8FKmG+z2v1Rn9NMnkbhu+z1n3cyc/NUk=";
  };

  glow = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "glow.yazi";
    rev = "main";
    hash = "sha256-mzW/ut/LTEriZiWF8YMRXG9hZ70OOC0irl5xObTNO40=";
  };

  hexyl = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "hexyl.yazi";
    rev = "main";
    hash = "sha256-ly/cLKl2y3npoT2nX8ioGOFcRXI4UXbD9Es/5veUhOU=";
  };

  ouch = pkgs.fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "main";
    hash = "sha256-g/ZHArXksRo49k9UBHap0CXzIdycQigjbdCzDK1VaLY=";
  };

  rich-preview = pkgs.fetchFromGitHub {
    owner = "AnirudhG07";
    repo = "rich-preview.yazi";
    rev = "main";
    hash = "sha256-celObHo9Y3pFCd1mTx1Lz77Tc22SJTleRblAkbH/RqY=";
  };

  yatline = pkgs.fetchFromGitHub {
    owner = "imsi32";
    repo = "yatline.yazi";
    rev = "main";
    hash = "sha256-RkQKZQAa5U9eMWk1Q0doueJZiuP4elUJ0dM1XKLSnDo=";
  };

  lazygit = pkgs.fetchFromGitHub {
    owner = "Lil-Dank";
    repo = "lazygit.yazi";
    rev = "main";
    hash = "sha256-OJJPgpSaUHYz8a9opVLCds+VZsK1B6T+pSRJyVgYNy8=";
  };

  githead = pkgs.fetchFromGitHub {
    owner = "llanosrocas";
    repo = "githead.yazi";
    rev = "main";
    hash = "sha256-LkoRydeFGaD/+p3Vax9FCk/QazWp1NiKojm1s5F3v88=";
  };

  kanagawa = pkgs.fetchFromGitHub {
    owner = "dangooddd";
    repo = "kanagawa.yazi";
    rev = "main";
    hash = "sha256-phwGd1i/n0mZH/7Ukf1FXwVgYRbXQEWlNRPCrmR5uNk=";
  };

  material-ocean = pkgs.fetchFromGitHub {
    owner = "myamusashi";
    repo = "material-ocean.yazi";
    rev = "main";
    hash = "sha256-5YGwMkQugoYv1TjMeZ70KLMRntFqbRnCURfekZaap2Y=";
  };

  fzf = pkgs.fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "fg.yazi";
    rev = "main";
    hash = "sha256-pFljxXAyUfu680+MhbLrI07RcukrPXgmIvtp3f6ZVvY=";
  };
}
