# Nix Style & Conventions

## Formatting
- 2-space indentation
- Max line width: 120 characters
- Use `nixfmt` for formatting

## File Naming
- Directories: kebab-case (e.g., `nix-homebrew`, `sketchybar`)
- Nix files: snake_case or kebab-case (e.g., `config.nix`, `home.nix`)

## Module Patterns
- Each tool/program gets its own directory under `modules/`
- Entry files named `config.nix` or `default.nix`
- Host-specific config in `modules/hosts/{hostname}.nix`
- Shared config in `modules/default.nix`

## Parameter Style
```nix
# Always destructure, use ... for unused
{ pkgs, hostname, username, ... }:
```

## Import Style
```nix
imports = [
  ./module-a/config.nix
  ./module-b
];
```

## Packages
```nix
home.packages = with pkgs; [
  package-a   # alphabetical preferred
  package-b
];
```

## Comments
- Minimal — only for non-obvious workarounds or constraints
- No trailing comments unless explaining a specific line

## Special Patterns
- `xdg.configFile` for dotfiles without Nix options
- `home.file` for arbitrary file placement relative to $HOME
- `builtins.toJSON` for generating JSON config files in Nix
- Per-hostname data via `let map = { maclop = ...; worklop = ...; }; in map.${hostname}`
- Catppuccin flavor: **macchiato** throughout
