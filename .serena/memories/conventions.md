# Conventions

## Formatting
- 2-space indentation; max 120 char line width
- `nixfmt` for all `.nix` files

## File Naming
- Directories: kebab-case; Nix files: `config.nix` or `default.nix` per module

## Module Pattern
- Each tool gets its own dir under `modules/`; host-specific in `modules/hosts/{hostname}.nix`
- New modules must be imported in `modules/default.nix` (or relevant parent)

## Parameter Style
```nix
{ pkgs, hostname, username, ... }:   # always destructure; ... for unused
```

## Import Style
```nix
imports = [ ./module-a/config.nix ./module-b ];
```

## Packages
```nix
home.packages = with pkgs; [ pkg-a pkg-b ];  # alphabetical preferred
```

## Per-host Conditionals
```nix
let map = { maclop = "val1"; worklop = "val2"; }; in map.${hostname}
```

## Dotfiles
- `xdg.configFile` for dotfiles without Nix options
- `home.file` for arbitrary `$HOME`-relative files
- `builtins.toJSON` for generating JSON config files in Nix

## Comments
- Minimal — only for non-obvious workarounds; no trailing comments unless explaining a line

## Theme
- Catppuccin **macchiato** flavor throughout (via catppuccin flake input)
