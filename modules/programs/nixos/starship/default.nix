{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.nixos.starship;
  colors = config.shellix.matugen.colors.palette;
in {
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = lib.mkDefault true;

      settings = {
        palette = "colors";
        palettes.colors = {
          error = colors.error.hex;
          color1 = colors.primary_fixed_dim.hex;
          color2 = colors.on_primary.hex;
          color3 = colors.on_surface_variant.hex;
          color4 = colors.surface_container.hex;
          color5 = colors.on_primary.hex;
          color6 = colors.surface_dim.hex;
          color7 = colors.surface.hex;
          color8 = colors.primary.hex;
          color9 = colors.tertiary.hex;
        };
        character = {
          success_symbol = "[ ](color9 bold)";
          error_symbol = "[ ](error bold)";
          vicmd_symbol = "[ ](color9 bold)";
        };
        os = {
          style = "bold ${colors.primary.hex}";
          disabled = lib.mkDefault false;
        };
        username = {
          disabled = lib.mkDefault false;
          show_always = lib.mkDefault true;
          style_user = colors.tertiary.hex;
        };
        hostname = {
          ssh_only = true;
          style = "bold ${colors.tertiary.hex}";
        };
        time = {
          format = "[](fg:color8 bg:color4)[ ](bg:color8 fg:color5)[](fg:color8 bg:color4)[(bg:color8 fg:color5) $time](fg:color3 bg:color4)[](fg:color4) ";
          disabled = false;
          time_format = "%R";
        };
        directory = {
          style = "bold ${colors.primary.hex}";
          format = "[](fg:color1 bg:color4)[󰉋 ](bg:color1 fg:color2)[ ](fg:color1 bg:color4)[$path ](fg:color3 bg:color4)[ ](fg:color4) ";
          truncation_length = 9;
          truncation_symbol = "";
          read_only = "🔐";

          substitutions = {
            "Documents" = "󰂺 ";
            "Downloads" = "󰉍 ";
            "Music" = "󱍙 ";
            "Pictures" = "󰉏 ";
            ".dots" = " ";
            ".config" = " ";
            "external_drive" = "󰉗 ";
            "Videos" = "󰃽 ";
            "Public" = "󰨷 ";
          };
        };
        git_branch = {
          style = "bold ${colors.secondary.hex}";
          format = "[](fg:color8 bg:color4)[ ](bg:color8 fg:color5)[](fg:color8 bg:color4)[(bg:color8 fg:color5) $branch](fg:color3 bg:color4)[](fg:color4) ";
        };
        git_status = {
          style = colors.tertiary.hex;
          conflicted = "🛠️";
          up_to_date = "☑️";
          untracked = "❓";
          stashed = "🗂️";
          modified = "📝";
          renamed = "🏷️";
          deleted = "🗑️";
        };
      };
    };
  };
}
