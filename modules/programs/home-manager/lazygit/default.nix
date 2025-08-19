{
  lib,
  config,
  ...
}: let
  cfg = config.shellix.programs.home;
  colors = config.shellix.matugen.colors.palette;
in {
  config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          scrollHeight = 2;
          scrollPastBottom = true;
          scrollOffMargin = 2;
          scrollOffBehavior = "margin";
          mouseEvents = true;
          mainPanelSplitMode = "flexible";
          theme = {
            activeBorderColor = [colors.on_background.hex "bold"];
            inactiveBorderColor = [colors.on_surface_variant.hex];
            searchingActiveBorderColor = [colors.primary.hex "bold"];
            optionsTextColor = [colors.secondary_fixed_dim.hex];
            selectedLineBgColor = [colors.surface_bright.hex];
            inactiveViewSelectedLineBgColor = [colors.error.hex "bold"];
            cherryPickedCommitFgColor = [colors.secondary_fixed_dim.hex];
            cherryPickedCommitBgColor = [colors.secondary_fixed.hex];
            markedBaseCommitFgColor = [colors.secondary_fixed_dim.hex];
            markedBaseCommitBgColor = [colors.tertiary.hex];
            unstagedChangesColor = [colors.error_container.hex];
            defaultFgColor = ["default"];
            commitLength = {
              show = true;
            };
            showListFooter = true;
            showFileTree = true;
            showNumstatInFilesView = false;
            showRandomTip = true;
            showCommandLog = true;
            showBottomLine = true;
            showPanelJumps = true;
            showIcons = false;
            nerdFontsVersion = "";
            showFileIcons = true;
            commitAuthorShortLength = 2;
            commitAuthorLongLength = 17;
            commitHashLength = 8;
            showBranchCommitHash = false;
            showDivergenceFromBaseBranch = "none";
            commandLogSize = 8;
            splitDiff = "auto";
            screenMode = "normal";
            border = "rounded";
            animateExplosion = true;
            portraitMode = "auto";
            filterMode = "substring";

            spinner = {
              frames = ["|" "/" "-" "\\"];
              rate = 50;
            };

            statusPanelView = "dashboard";
            switchToFilesAfterStashPop = true;
            switchToFilesAfterStashApply = true;
            switchTabsWithPanelJumpKeys = false;
          };
        };

        git = {
          merging = {
            manualCommit = false;
            args = "";
            squashMergeMessage = "Squash merge {{selectedRef}} into {{currentBranch}}";
          };

          mainBranches = ["master" "main"];
        };
      };
    };
  };
}
