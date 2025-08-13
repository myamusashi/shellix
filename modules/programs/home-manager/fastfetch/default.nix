{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.home;
in {
  config = lib.mkIf cfg.enable {
    programs.fastfetch = {
      enable = lib.mkDefault true;
      settings = {
        logo = {
          type = "kitty-icat";
          source = "~/Pictures/wallpapers/neko-cat.gif";
          padding = {
            top = 3;
          };
        };
        general = {
          multithreading = lib.mkDefault true;
          dsForceDrm = lib.mkDefault true;
        };
        display = {
          separator = " ➜ ";
        };
        modules = [
          # {
          #   type = "title";
          #   format = "                                 {6}{7}{8}";
          # }
          {
            key = "     OS         ";
            keyColor = "white";
            type = "os";
          }
          {
            key = "    󰌢 Machine    ";
            keyColor = "white";
            type = "host";
          }
          {
            key = "     Kernel     ";
            keyColor = "white";
            type = "kernel";
          }
          {
            key = "     InitSys    ";
            keyColor = "white";
            type = "initsystem";
          }
          {
            key = "    󰅐 Uptime     ";
            keyColor = "blue";
            type = "uptime";
          }
          {
            key = "     WM         ";
            keyColor = "blue";
            type = "wm";
          }
          {
            key = "     Font       ";
            keyColor = "blue";
            type = "terminalfont";
          }
          {
            key = "     Packages   ";
            keyColor = "cyan";
            type = "packages";
          }
          {
            key = "     Theme      ";
            keyColor = "cyan";
            type = "theme";
          }
          {
            key = "     Terminal   ";
            keyColor = "cyan";
            type = "terminal";
          }
          {
            key = "    󱁋 Disk       ";
            keyColor = "cyan";
            type = "Disk";
          }
        ];
      };
    };
  };
}
