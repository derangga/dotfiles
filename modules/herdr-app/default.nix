{ pkgs, lib, ... }:
let
  herdrReview = pkgs.callPackage ../llm-agents/herdr-review.nix { };
  release = "${herdrReview}/herdr-app-mod";
  mod = "${release}/dist/mods/herdr-review";
  # No releases yet, so pinned to a commit. Bump rev and hash to update. Holds the beads mod, the paddock layout
  # and the paddock-* mods, built from TypeScript in that repo.
  herdrMods = "${
    pkgs.fetchFromGitHub {
      owner = "derangga";
      repo = "herdr-mods";
      rev = "5b9fa2cda40f078b64aae2374d41ae22c1f6b2bd";
      hash = "sha256-SPTq2M+N4E9R62FGU4/sq0AmYC6sVaFeRgsEBe65r0E=";
    }
  }/herdr-app";
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
    # Paddock layout with review and beads toggles in the tab bar. Select it in herdr-app; shared.json is not managed.
    put ${herdrMods}/layouts/paddock.json layouts/paddock.json
    put ${herdrMods}/layouts/paddock.svg layouts/paddock.svg
    # beads and the paddock-* clones of Herdr's mods (herdr-app 0.1.16). Herdr restores its own mods on every
    # start, so only clones can change them.
    (cd ${herdrMods}/mods && find . -type f) | while read -r f; do put "${herdrMods}/mods/$f" "mods/$f"; done

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
