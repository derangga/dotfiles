# Project Structure

```
nix/
├── flake.nix                      # Entry point; defines maclop + worklop darwinConfigurations
├── flake.lock
├── README.md                      # User-facing docs (app table, usage, config steps)
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
    ├── aerospace/                 # Aerospace window manager
    ├── catppuccin/default.nix     # Catppuccin theme settings (per-app enable flags)
    ├── ghost/                     # Ghostty face shader driven by herdr AI state; script/ (Go) + .glsl shader
    ├── git/                       # Git config (per-hostname user.name)
    ├── llm-agents/default.nix     # Claude Code, OpenCode, Beads, RTK, Serena, herdr, hunk, fff-mcp
    ├── nixvim/                    # Neovim via nixvim flake (NOT LazyVim)
    │   ├── plugins/                 # Plugin configurations (completion, lsp, ui, etc.)
    │   └── docs/                    # Neovim docs
    ├── presenterm/                 # Presenterm + mermaid-cli; config.yaml + puppeteer.json
    ├── sketchybar/                 # Sketchybar menu bar (Lua-based config), config.nix + lua/
    ├── starship/
    │   ├── no-version.nix          # Starship prompt (active variant, imported in modules/default.nix)
    │   └── powerline.nix           # Starship prompt (alternate variant, unused)
    ├── terminal/
    │   ├── default.nix             # Terminal module entry
    │   ├── ghostty.nix             # Ghostty terminal config
    │   ├── kitty.nix               # Kitty terminal config
    │   ├── options.nix             # Terminal options/selector (driven by `terminal` specialArg)
    │   └── shaders/                # GLSL shaders for terminal eye candy
    └── hosts/
        ├── maclop.nix              # Personal host overrides
        └── worklop.nix             # Work host overrides
```

## modules/default.nix Programs (shared across hosts)
atuin, bat, btop, eza, gh, gh-dash, lazygit, tmux, vscode, yazi, zoxide, zsh (Oh-My-Zsh)
Plus imports: aerospace, catppuccin, ghost, git, llm-agents, terminal, nixvim, presenterm, starship/no-version.nix, sketchybar/config.nix, hosts/${hostname}.nix

## System Packages (darwin/configuration.nix)
ffmpeg, gnupg, mkalias, tree
