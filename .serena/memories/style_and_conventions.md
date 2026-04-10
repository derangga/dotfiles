# Style & Conventions

## Nix Files
- **Indentation**: 2 spaces
- **Line width**: 120 characters max
- **Formatter**: `nixfmt file.nix`
- **File naming**: kebab-case for directories, descriptive names for `.nix` files
- **Comments**: Minimal — Nix is self-documenting. Only for workarounds or complex logic.

## Function Signatures
- Pattern matching: `{ pkgs, hostname, username, ... }:`
- Always include `...` ellipsis for unused arguments
- List required parameters explicitly

## Import Patterns
- Use `imports = [ ... ];` at top of files
- Use relative `./` paths for local modules
- Dynamic host config via `${hostname}` substitution

## Package Lists
- Use `with pkgs;` for package lists
- Prefer alphabetical ordering

## Module Organization
- Each tool/program gets its own directory under `modules/`
- Host-specific configs: `modules/hosts/{hostname}.nix` and `darwin/homebrew/hosts/{hostname}.nix`
- Shared configs in `modules/default.nix`

## Lua Files (sketchybar, lazyvim plugins)
- **Indentation**: 2 spaces (per stylua.toml)
- **Column width**: 120 (per stylua.toml)

## Adding a New Host
1. Add entry in `flake.nix` under `darwinConfigurations`
2. Create `modules/hosts/{hostname}.nix`
3. Create `darwin/homebrew/hosts/{hostname}.nix`
