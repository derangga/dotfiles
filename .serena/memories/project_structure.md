# Project Structure

```
nix/
├── flake.nix              # Entry point — defines darwinConfigurations for each host
├── flake.lock             # Locked dependency versions
├── CLAUDE.md              # Project instructions for AI agents
├── AGENTS.md              # Agent instructions
├── home/                  # home-manager root (home.nix)
├── darwin/
│   ├── configuration.nix  # System-wide nix-darwin settings
│   ├── terminal.nix       # Terminal system settings
│   └── homebrew/
│       ├── default.nix    # Homebrew casks/formulae shared config
│       └── hosts/
│           ├── maclop.nix   # Homebrew config for personal laptop
│           └── worklop.nix  # Homebrew config for work laptop
└── modules/
    ├── default.nix        # Shared module entry point
    ├── hosts/
    │   ├── maclop.nix     # derangga (personal laptop) user config
    │   └── worklop.nix    # sociolla (work laptop) user config
    ├── aerospace/         # Window manager config
    ├── catppuccin/        # Theme config (config.nix)
    ├── git/               # Git config
    ├── lazyvim/           # Neovim (LazyVim) config + Lua plugins
    │   ├── config.nix
    │   └── plugins/       # Lua plugin files
    ├── sketchybar/        # Menu bar (Lua-based config + C helpers)
    ├── starship/          # Shell prompt
    └── terminal/          # Terminal emulators (kitty.nix, etc.) + shaders
```

## Key Files
- `flake.nix` — defines two hosts via `mkDarwinConfig` helper
- `darwin/configuration.nix` — system-wide settings
- `home/home.nix` — home-manager entry, imports per-user module
- `modules/hosts/{hostname}.nix` — user-specific packages and programs
- `darwin/homebrew/default.nix` — shared Homebrew casks/taps
- `darwin/homebrew/hosts/{hostname}.nix` — host-specific Homebrew packages
