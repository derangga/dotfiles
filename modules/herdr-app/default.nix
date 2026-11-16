{ pkgs, lib, ... }:
let
  herdrReview = pkgs.callPackage ../llm-agents/herdr-review.nix { };
  release = "${herdrReview}/herdr-app-mod";
  mod = "${release}/dist/mods/herdr-review";
  # No releases yet, so pinned to a commit. Bump rev and hash to update.
  beads = "${
    pkgs.fetchFromGitHub {
      owner = "derangga";
      repo = "herdr-beads-ui";
      rev = "4f5f2ef479720786225c80bc14124a8c8483c8d7";
      hash = "sha256-yN46B93+R0yG1wb1A8S0QBWaSln9QST4hNep4+dLyXs=";
    }
  }/herdr-app/mods/beads";
in
{
  # herdr-app watches these files and rewrites some siblings itself (shared.json, view.json), so they
  # are copied on activation instead of linked into the read-only store. Rebuilding overwrites edits made
  # in the app folder. main.js goes last because saving it reloads the mod.
  home.activation.configureHerdrApp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    app="$HOME/.config/herdr-app"
    put() { $DRY_RUN_CMD install -Dm644 "$1" "$app/$2"; }

    put ${./settings.json} settings.json
    put ${./keys.json} keys.json
    put ${./catppuccin-macchiato.json} themes/catppuccin-macchiato.json
    # Upstream herdr-review layout plus a beads-toggle block in the tab bar.
    put ${./herdr-review-layout.json} layouts/herdr-review.json
    # Clones of Herdr's agents and workspace-chrome mods (herdr-app 0.1.16) that fold the sidebar to 44px
    # instead of 76px. Herdr restores its own mods on every start, so only clones can change this.
    (cd ${./mods} && find . -type f) | while read -r f; do put "${./mods}/$f" "mods/$f"; done

    for f in ${beads}/icons/*.svg; do put "$f" "mods/beads/icons/$(basename "$f")"; done
    put ${beads}/mod.json mods/beads/mod.json
    put ${beads}/main.js mods/beads/main.js

    for f in ${mod}/icons/*.svg; do put "$f" "mods/herdr-review/icons/$(basename "$f")"; done
    put ${mod}/mod.json mods/herdr-review/mod.json
    put ${mod}/VERSION mods/herdr-review/VERSION
    $DRY_RUN_CMD install -Dm755 ${mod}/fetch-binary.sh "$app/mods/herdr-review/fetch-binary.sh"
    # Copy beside the old binary and rename, so a running panel never execs a half-written file.
    $DRY_RUN_CMD install -Dm755 ${herdrReview}/bin/herdr-review "$app/mods/herdr-review/bin/herdr-review.new"
    $DRY_RUN_CMD mv "$app/mods/herdr-review/bin/herdr-review.new" "$app/mods/herdr-review/bin/herdr-review"
    echo ${herdrReview.version} > "$app/mods/herdr-review/bin/herdr-review.version"
    put ${mod}/main.js mods/herdr-review/main.js
  '';
}
