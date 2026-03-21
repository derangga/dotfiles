# Task Completion Checklist

When a coding task is completed, follow these steps:

## Validation
1. **Format Nix files**: Run `nixfmt` on any modified `.nix` files
2. **Check syntax**: `sudo darwin-rebuild check --flake ~/nix#<hostname>`
3. **Test build**: `sudo darwin-rebuild build --flake ~/nix#<hostname>`

## Notes
- There is **no test framework** — successful rebuild validates the configuration
- Manual testing is required for UI components (sketchybar, aerospace)
- Lua files should conform to `stylua.toml` settings
- No CI/CD pipeline — all testing is local
