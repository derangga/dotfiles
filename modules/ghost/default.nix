{
  config,
  lib,
  pkgs,
  terminal,
  ...
}:
lib.mkIf (terminal == "ghostty") (
  let
    stateDir = "${config.home.homeDirectory}/.local/state/ghost-in-the-machine";

    # Face placement. The shader centres the face inside herdr's sidebar, so
    # sidebarCols must match herdr's own sidebar_width (see session.json) or the
    # face drifts out over terminal text. cellWidth is upstream's value for
    # their font; retune by eye with `ghost-watch idle`.
    sidebarCols = 26;
    cellWidth = 16;

    variants = pkgs.runCommand "ghost-variants" { } ''
      mkdir -p "$out"
      for pair in idle:0 thinking:1 working:2 done:3 error:4; do
        name="''${pair%%:*}"
        forced="''${pair##*:}"
        ${pkgs.gawk}/bin/awk \
          -v forced="$forced" \
          -v cols="${toString sidebarCols}" \
          -v cell="${toString cellWidth}" '
          $0 == "const int FORCED_STATE = -1;" {
            print "const int FORCED_STATE = " forced ";"; next
          }
          /^const float SIDEBAR_COLS/ {
            print "const float SIDEBAR_COLS = " cols ".0;"; next
          }
          /^const float SIDEBAR_CELL_WIDTH/ {
            print "const float SIDEBAR_CELL_WIDTH = " cell ".0;"; next
          }
          { print }
        ' ${./ghost-in-the-machine.glsl} > "$out/$name.glsl"
      done
      grep -q "FORCED_STATE = 2;" "$out/working.glsl" || {
        echo "substitution missed FORCED_STATE; upstream shader changed" >&2
        exit 1
      }
    '';

    # Stdlib only, hence vendorHash = null -- no vendor dir, no network fetch.
    ghostWatch = pkgs.buildGoModule {
      pname = "ghost-watch";
      version = "0";
      src = ./script;
      vendorHash = null;
      # There are no go tests; the self-check is the check, and it is hermetic.
      doCheck = false;
      postInstall = "$out/bin/ghost-watch --selfcheck";
    };
  in
  {
    home.packages = [ ghostWatch ];

    home.activation.ghostStateDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg stateDir}
    '';

    launchd.agents.ghost-in-the-machine = {
      enable = true;
      config = {
        ProgramArguments = [ "${ghostWatch}/bin/ghost-watch" ];
        EnvironmentVariables = {
          GHOST_VARIANTS = "${variants}";
          GHOST_FRAGMENT = "${stateDir}/ghostty.conf";
        };
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Background";
        StandardErrorPath = "${stateDir}/watch.log";
      };
    };
  }
)
