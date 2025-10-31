{pkgs, ...}: {
  # https://github.com/yazi-rs/plugins
  official-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "main";
    hash = "sha256-7vsqHvdNimH/YVWegfAo7DfJ+InDr3a1aNU0f+gjcdw=";
  };

  # https://github.com/boydaihungst/mediainfo.yazi
  mediainfo = pkgs.fetchFromGitHub {
    owner = "boydaihungst";
    repo = "mediainfo.yazi";
    rev = "master";
    hash = "sha256-GObz6kpBTT1HuWgsAWlbbzCw2GxZGKLTWaUKKztiTaw=";
  };

  # https://github.com/macydnah/office.yazi
  office = pkgs.fetchFromGitHub {
    owner = "macydnah";
    repo = "office.yazi";
    rev = "main";
    hash = "sha256-QFto48D+Z8qHl7LHoDDprvr5mIJY8E7j37cUpRjKdNk=";
  };
  # https://github.com/ahkohd/eza-preview.yazi
  eza-preview = pkgs.fetchFromGitHub {
    owner = "ahkohd";
    repo = "eza-preview.yazi";
    rev = "main";
    hash = "sha256-Q8RwpzUkZkz8FKmG+z2v1Rn9NMnkbhu+z1n3cyc/NUk=";
  };
  # https://github.com/Reledia/glow.yazi
  glow = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "glow.yazi";
    rev = "main";
    hash = "sha256-mzW/ut/LTEriZiWF8YMRXG9hZ70OOC0irl5xObTNO40=";
  };
  # https://github.com/Reledia/hexyl.yazi
  hexyl = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "hexyl.yazi";
    rev = "main";
    hash = "sha256-ly/cLKl2y3npoT2nX8ioGOFcRXI4UXbD9Es/5veUhOU=";
  };
  # https://github.com/ndtoan96/ouch.yazi
  ouch = pkgs.fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "main";
    hash = "sha256-C0wG8NQ+zjAMfd+J39Uvs3K4U6e3Qpo1yLPm2xcsAaI=";
  };
  # https://github.com/AnirudhG07/rich-preview.yazi
  rich-preview = pkgs.fetchFromGitHub {
    owner = "AnirudhG07";
    repo = "rich-preview.yazi";
    rev = "main";
    hash = "sha256-celObHo9Y3pFCd1mTx1Lz77Tc22SJTleRblAkbH/RqY=";
  };
  # https://github.com/imsi32/yatline.yazi
  yatline = pkgs.fetchFromGitHub {
    owner = "imsi32";
    repo = "yatline.yazi";
    rev = "main";
    hash = "sha256-RkQKZQAa5U9eMWk1Q0doueJZiuP4elUJ0dM1XKLSnDo=";
  };
  # https://github.com/Lil-Dank/lazygit.yazi
  lazygit = pkgs.fetchFromGitHub {
    owner = "Lil-Dank";
    repo = "lazygit.yazi";
    rev = "main";
    hash = "sha256-OJJPgpSaUHYz8a9opVLCds+VZsK1B6T+pSRJyVgYNy8=";
  };
  # https://github.com/llanosrocas/githead.yazi
  githead = pkgs.fetchFromGitHub {
    owner = "llanosrocas";
    repo = "githead.yazi";
    rev = "main";
    hash = "sha256-LkoRydeFGaD/+p3Vax9FCk/QazWp1NiKojm1s5F3v88=";
  };
  # https://github.com/dangooddd/kanagawa.yazi
  kanagawa = pkgs.fetchFromGitHub {
    owner = "dangooddd";
    repo = "kanagawa.yazi";
    rev = "main";
    hash = "sha256-nGFiAgVWfq7RkuGGCt07zm3z7ZTGiIPIR319ojPfdUk=";
  };
  # https://github.com/myamusashi/material-ocean.yazi
  material-ocean = pkgs.fetchFromGitHub {
    owner = "myamusashi";
    repo = "material-ocean.yazi";
    rev = "main";
    hash = "sha256-5YGwMkQugoYv1TjMeZ70KLMRntFqbRnCURfekZaap2Y=";
  };
  # https://github.com/DreamMaoMao/fg.yazi
  fzf = pkgs.fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "fg.yazi";
    rev = "main";
    hash = "sha256-PNZngyiWuzw2bmJ4v66er9HEAcD5z0Dr6iKYwcxJwf0=";
  };
  # https://github.com/Deepak22903/kdeconnect-send.yazi
  kdeconnect-send = pkgs.fetchFromGitHub {
    owner = "Deepak22903";
    repo = "kdeconnect-send.yazi";
    rev = "main";
    hash = "sha256-xza+TXFGEqkPDVT2er5iisVd9QdGwJNKiUcu7Mjpeug=";
  };
  # https://github.com/AnirudhG07/custom-shell.yazi
  custom-shell = pkgs.fetchFromGitHub {
    owner = "AnirudhG07";
    repo = "custom-shell.yazi";
    rev = "main";
    hash = "sha256-hJVFZvcHgcjmcwUUGs1Q668KjeLSCEVuAhAD1A8ZM90=";
  };
}
