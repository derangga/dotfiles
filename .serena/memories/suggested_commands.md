# Suggested Commands

## Build & Deploy
| Command | Description |
|---------|-------------|
| `sudo darwin-rebuild switch --flake ~/nix#<hostname>` | Build and apply configuration |
| `sudo darwin-rebuild build --flake ~/nix#<hostname>` | Build without switching |
| `sudo darwin-rebuild check --flake ~/nix#<hostname>` | Check/validate configuration |
| `nix-collect-garbage -d` | Clean up old generations |
| `nix flake update` | Update all flake inputs |

## Shell Aliases (defined in modules/default.nix)
| Alias | Expands To |
|-------|------------|
| `drb` | `sudo darwin-rebuild switch --flake ~/nix#<hostname>` |
| `ngc` | `nix-collect-garbage -d` |
| `lg` | `lazygit` |

## Formatting
| Command | Description |
|---------|-------------|
| `nixfmt <file>.nix` | Format a Nix file |

## System Utilities (Darwin)
| Command | Description |
|---------|-------------|
| `git` | Version control |
| `lazygit` / `lg` | Git TUI |
| `gh` | GitHub CLI |
| `bat` | Better cat |
| `eza` | Better ls (aliased) |
| `fzf` | Fuzzy finder |
| `yazi` / `y` | File manager |
| `btop` | System monitor |

## Development Workflow
1. Edit relevant `.nix` files
2. Validate: `sudo darwin-rebuild check --flake ~/nix#<hostname>`
3. Test build: `sudo darwin-rebuild build --flake ~/nix#<hostname>`
4. Apply: `sudo darwin-rebuild switch --flake ~/nix#<hostname>` (or `drb`)
