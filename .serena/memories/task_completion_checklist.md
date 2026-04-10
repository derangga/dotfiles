# Task Completion Checklist

After making changes to any Nix configuration file:

1. **Format** changed files: `nixfmt file.nix`
2. **Validate** syntax: `sudo darwin-rebuild check --flake ~/nix#{hostname}`
3. **Test build** (optional): `sudo darwin-rebuild build --flake ~/nix#{hostname}`
4. **Apply** changes: `sudo darwin-rebuild switch --flake ~/nix#{hostname}`

> No unit tests — successful rebuild = passing test.
> Manual testing required for UI components (sketchybar, aerospace).
> For Lua plugin files (lazyvim/sketchybar), no separate linting step needed.
