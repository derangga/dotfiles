# Task Completion Checklist

After making changes to Nix configuration files:

1. **Format** changed `.nix` files with `nixfmt <file>`
2. **Validate syntax**: `sudo darwin-rebuild check --flake ~/nix#<hostname>`
3. **Test build** (optional, no side effects): `sudo darwin-rebuild build --flake ~/nix#<hostname>`
4. **Apply**: `sudo darwin-rebuild switch --flake ~/nix#<hostname>` — requires sudo, user must run
5. **Commit** changes with a descriptive message

## Important Reminders
- Do NOT run `darwin-rebuild` commands yourself — they require sudo
- Always check both `maclop` and `worklop` hosts if change is shared/system-level
- Lua files (sketchybar, neovim) don't need `darwin-rebuild` — they're symlinked at build time
- If adding a new module, import it in `modules/default.nix` or the relevant parent file
