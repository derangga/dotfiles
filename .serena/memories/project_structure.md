# Project Structure

```
nix/
├── flake.nix              # Entry point — defines darwinConfigurations for each host
├── flake.lock             # Locked dependency versions
├── CLAUDE.md              # Project instructions for AI agents
├── home/                  # home-manager root (home.nix)
├── darwin/                # System-level nix-darwin config (configuration.nix)
└── modules/               # Modular configurations
    ├── default.nix        # Shared module entry
    ├── hosts/
    │   ├── maclop.nix     # derangga (personal laptop)
    │   └── worklop.nix    # sociolla (work laptop)
    ├── aerospace/         # Window manager
    ├── catppuccin/        # Theme
    ├── lazyvim/           # Neovim (LazyVim) config + Lua plugins
    ├── sketchybar/        # Menu bar (Lua-based config + C helpers)
    ├── starship/          # Shell prompt
    └── terminal/          # Terminal emulators (kitty, ghostty) + shaders
```

## Key Files
- `flake.nix` — defines two hosts via `mkDarwinConfig` helper
- `darwin/configuration.nix` — system-wide settings
- `home/home.nix` — home-manager entry, imports per-user module
- `modules/hosts/{username}.nix` — user-specific packages and programs
