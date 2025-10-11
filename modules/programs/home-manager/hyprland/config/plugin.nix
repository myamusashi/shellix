{
  config,
  lib,
  ...
}: let
  cfg = config.shellix.programs.home.hyprland.plugins;
in {
  plugin = lib.mkIf cfg.enable {
    hyprscrolling = lib.mkIf cfg.scrolling.enable {
      fullscreen_on_one_column = true;
    };

    hy3 = lib.mkIf cfg.hy3.enable {
      # 0 - always show gaps
      # 1 - hide gaps with a single window onscreen
      # 2 - 1 but also show the window border
      no_gaps_when_only = 0; # default: 0

      # 0 = remove the nested group
      # 1 = keep the nested group
      # 2 = keep the nested group only if its parent is a tab group
      node_collapse_policy = 0; # default: 2

      # offset from group split direction when only one window is in a group
      group_inset = 10; # default: 10

      # if a tab group will automatically be created for the first window spawned in a workspace
      tab_first_window = true;

      tabs = {
        height = 5; # default: 15
        padding = 5; # default: 5

        # the tab bar should animate in/out from the top instead of below the window
        from_top = false; # default: false
        rounding = 3; # default: 3
        render_text = false; # default: true
        text_center = false; # default: false
        text_font = "Sans"; # default: Sans
        text_height = 5; # default: 8
        text_padding = 1; # default: 3
        col = {
          active = "$background";
          urgent = "$on_tertiary";
          inactive = "$shadow";

          text = {
            active = "$primary";
            urgent = "$primary";
            inactive = "$primary";
          };
        };
      };

      autotile = {
        enable = true; # default: false;
        # make autotile-created groups ephemeral
        ephemeral_groups = true; # default: true

        # if a window would be squished smaller than this width, a vertical split will be created
        # -1 = never automatically split vertically
        # 0 = always automatically split vertically
        # <number> = pixel height to split at
        trigger_width = 0; # default: 0

        # if a window would be squished smaller than this height, a horizontal split will be created
        # -1 = never automatically split horizontally
        # 0 = always automatically split horizontally
        # <number> = pixel height to split at
        trigger_height = 0; # default: 0

        # a space or comma separated list of workspace ids where autotile should be enabled
        # it's possible to create an exception rule by prefixing the definition with "not:"
        # workspaces = 1,2 # autotiling will only be enabled on workspaces 1 and 2
        # workspaces = not:1,2 # autotiling will be enabled on all workspaces except 1 and 2
        "workspaces" = "all"; # default: all
      };
    };

    dynamic-cursors = lib.mkIf cfg.hypr-dynamic-cursors.enable {
      # enables the plugin
      enabled = true;

      # sets the cursor behaviour, supports these values:
      # tilt    - tilt the cursor based on x-velocity
      # rotate  - rotate the cursor based on movement direction
      # stretch - stretch the cursor shape based on direction and velocity
      # none    - do not change the cursors behaviour
      mode = "stretch";

      # minimum angle difference in degrees after which the shape is changed
      # smaller values are smoother, but more expensive for hw cursors
      threshold = 1;

      # for mode = rotate
      rotate = {
        # length in px of the simulated stick used to rotate the cursor
        # most realistic if this is your actual cursor size
        length = 20;

        # clockwise offset applied to the angle in degrees
        # this will apply to ALL shapes
        offset = 0.0;
      };

      # for mode = tilt
      tilt = {
        # controls how powerful the tilt is, the lower, the more power
        # this value controls at which speed (px/s) the full tilt is reached
        limit = 5000;

        # relationship between speed and tilt, supports these values:
        # linear             - a linear function is used
        # quadratic          - a quadratic function is used (most realistic to actual air drag)
        # negative_quadratic - negative version of the quadratic one, feels more aggressive
        function = "negative_quadratic";
      };

      # for mode = stretch
      stretch = {
        # controls how much the cursor is stretched
        # this value controls at which speed (px/s) the full stretch is reached
        limit = 3000;

        # relationship between speed and stretch amount, supports these values:
        # linear             - a linear function is used
        # quadratic          - a quadratic function is used
        # negative_quadratic - negative version of the quadratic one, feels more aggressive
        function = "negative_quadratic";
      };

      # configure shake to find
      # magnifies the cursor if its is being shaken
      shake = {
        # enables shake to find
        enabled = true;

        # use nearest-neighbour (pixelated) scaling when shaking
        # may look weird when effects are enabled
        nearest = true;

        # controls how soon a shake is detected
        # lower values mean sooner
        threshold = 30.0;

        # magnification level immediately after shake start
        base = 4.0;
        # magnification increase per second when continuing to shake
        speed = 4.0;
        # how much the speed is influenced by the current shake intensitiy
        influence = 0.0;

        # maximal magnification the cursor can reach
        # values below 1 disable the limit (e.g. 0)
        limit = 0.0;

        # time in millseconds the cursor will stay magnified after a shake has ended
        timeout = 2000;

        # show cursor behaviour `tilt`, `rotate`, etc. while shaking
        effects = false;

        # enable ipc events for shake
        ipc = false;
      };
    };
  };
}
