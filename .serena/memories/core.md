# Core

nix-darwin system configuration flake for macOS (aarch64-darwin). Manages two machines:
- `maclop` — personal laptop, username: `derangga`
- `worklop` — work laptop, username: `sociolla`

## Entry Points
- `flake.nix` — defines `darwinConfigurations` for both hosts via `mkDarwinConfig`
- `darwin/configuration.nix` — system-level packages, fonts, defaults
- `home/home.nix` — home-manager entry, imports `modules/default.nix`
- `modules/default.nix` — root home-manager module, imports all sub-modules + `hosts/${hostname}.nix`

## Key Module Directories
- `modules/aerospace/` — window manager
- `modules/catppuccin/` — theme (flavor: macchiato)
- `modules/git/` — git config (hostname-conditional user.name)
- `modules/llm-agents/` — AI tools (claude-code, opencode, beads, rtk, serena) via flake inputs
- `modules/nixvim/` — Neovim via nixvim flake (plugins, keymaps, autocmds, options)
- `modules/presenterm/` — presentation tool + mermaid-cli
- `modules/sketchybar/` — menu bar, Lua-based config
- `modules/starship/` — shell prompt (nosymbol + powerline variants)
- `modules/terminal/` — Ghostty + Kitty terminal configs, GLSL shaders
- `modules/hosts/` — host-specific home-manager config

See `mem:tech_stack` for flake inputs. See `mem:conventions` for code style. See `mem:suggested_commands` for CLI usage. See `mem:task_completion` for task checklist.
