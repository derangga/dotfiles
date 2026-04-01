# Suggested Commands

## Build & Apply
```bash
sudo darwin-rebuild switch --flake ~/nix#{hostname}   # Build and apply (drb alias)
sudo darwin-rebuild build --flake ~/nix#{hostname}    # Build without switching
sudo darwin-rebuild check --flake ~/nix#{hostname}    # Syntax/config validation
```

## Cleanup
```bash
nix-collect-garbage -d   # Remove old generations (ngc alias)
```

## Formatting
```bash
nixfmt file.nix   # Format a Nix file
```

## Aliases (defined in user config)
- `drb` → `sudo darwin-rebuild switch --flake ~/nix#{hostname}`
- `ngc` → `nix-collect-garbage -d`
- `lg` → `lazygit`

## System Utilities (Darwin/macOS)
```bash
git, ls, cd, grep, find   # Standard unix tools
lazygit (lg)              # Git TUI
```
