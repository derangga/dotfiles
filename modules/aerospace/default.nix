{ pkgs, lib, ... }:
let
  workspaces = map toString (lib.range 1 9);

  workspaceBindings = lib.mergeAttrsList (
    map (n: {
      "alt-${n}" = "workspace ${n}";
      "alt-shift-${n}" = "move-node-to-workspace ${n}";
    }) workspaces
  );
in
{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      config-version = 2;
      persistent-workspaces = workspaces;

      after-login-command = [ ];
      after-startup-command = [ ];
      start-at-login = true;
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 30;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      key-mapping.preset = "qwerty";
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
      ];

      on-window-detected = [
        {
          "if".app-id = "com.mitchellh.ghostty";
          run = [ "layout tiling" ];
        }
      ];

      gaps = {
        inner.horizontal = 10;
        inner.vertical = 10;
        outer.left = 8;
        outer.bottom = 8;
        outer.top = [
          { monitor."built-in" = 12; }
          50
        ];
        outer.right = 8;
      };

      mode.main.binding = {
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-shift-minus = "resize smart -50";
        alt-shift-equal = "resize smart +50";

        alt-shift-f = "fullscreen";

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        alt-f = "layout floating tiling";
        alt-shift-semicolon = "mode service";
      }
      // workspaceBindings;

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        r = [
          "flatten-workspace-tree"
          "mode main"
        ];
        f = [
          "layout floating tiling"
          "mode main"
        ];
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];

        alt-shift-h = [
          "join-with left"
          "mode main"
        ];
        alt-shift-j = [
          "join-with down"
          "mode main"
        ];
        alt-shift-k = [
          "join-with up"
          "mode main"
        ];
        alt-shift-l = [
          "join-with right"
          "mode main"
        ];
      };
    };
  };
}
