# Project Structure

```
nix/
├── flake.nix                      # Entry point; defines maclop + worklop darwinConfigurations
├── flake.lock
├── home/home.nix                  # home-manager entry; imports modules/default.nix
├── darwin/
│   ├── configuration.nix          # System-level config (packages, fonts, defaults)
│   ├── terminal.nix               # Terminal-related system config
│   └── homebrew/
│       ├── default.nix            # Shared Homebrew config
│       └── hosts/
│           ├── maclop.nix         # Personal machine Homebrew casks/formulae
│           └── worklop.nix        # Work machine Homebrew casks/formulae
└── modules/
    ├── default.nix                # Root home-manager module; imports all sub-modules + host config
    ├── aerospace/config.nix       # Aerospace window manager
    ├── catppuccin/config.nix      # Catppuccin theme settings
    ├── git/config.nix             # Git config (per-hostname user.name)
    ├── neovim/config.nix          # Neovim (LazyVim-based)
    │   └── lazyvim/               # LazyVim Lua config (plugins, keymaps, etc.)
    ├── presenterm/config.nix      # Presenterm + mermaid-cli; config.yaml + puppeteer.json
    ├── sketchybar/config.nix      # Sketchybar menu bar (Lua-based config)
    │   └── lua/                   # Full Lua sketchybar config (items, widgets, helpers)
    ├── starship/
    │   ├── nosymbol.nix           # Starship prompt (no-symbol variant)
    │   └── powerline.nix          # Starship prompt (powerline variant)
    ├── terminal/
    │   ├── default.nix            # Terminal module entry
    │   ├── ghostty.nix            # Ghostty terminal config
    │   ├── kitty.nix              # Kitty terminal config
    │   ├── options.nix            # Terminal options/selector
    │   └── shaders/               # GLSL shaders for terminal eye candy
    └── hosts/
        ├── maclop.nix             # Personal: flutter, cocoapods, vscode, OBS catppuccin
        └── worklop.nix            # Work: pm2
```

## modules/default.nix Programs (shared across hosts)
bat, btop, claude-code, eza, fzf, gh, gh-dash, lazygit, opencode, tmux, yazi, zed-editor, zoxide, zsh (Oh-My-Zsh)

## System Packages (darwin/configuration.nix)
bun, cargo, fnm, ffmpeg, gnupg, go, mkalias, nixd, pnpm, rustc, rust-analyzer, tree, uv
