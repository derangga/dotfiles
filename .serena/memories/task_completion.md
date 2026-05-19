# Task Completion

After making Nix config changes:

1. **Format** changed `.nix` files: `nixfmt <file>`
2. **Validate**: `sudo darwin-rebuild check --flake ~/nix#<hostname>` (safe, no side effects)
3. **Build** (optional): `sudo darwin-rebuild build --flake ~/nix#<hostname>`
4. **Apply**: `sudo darwin-rebuild switch --flake ~/nix#<hostname>` — requires sudo, user must run
5. **Commit** with descriptive message

## Invariants
- Never run `darwin-rebuild` yourself — always tell the user to run it
- Check both hosts if change is to shared/system-level config
- Lua files (sketchybar, nixvim plugins) are symlinked — no rebuild needed for content edits after initial build
- Adding a new module requires importing it in `modules/default.nix` or relevant parent
