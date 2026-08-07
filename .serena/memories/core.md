# Core

nix-darwin system configuration flake for macOS (aarch64-darwin). Manages two machines:
- `maclop` — personal laptop, username: `derangga`
- `worklop` — work laptop, username: `sociolla`

Both hosts currently set `terminal = "ghostty"` in `flake.nix`.

## Entry Points
- `flake.nix` — defines `darwinConfigurations` for both hosts via `mkDarwinConfig { hostname, username, terminal }`
- `darwin/configuration.nix` — system-level packages, fonts, defaults; imports `darwin/homebrew` + `darwin/terminal.nix`
- `modules/default.nix` — home-manager entry point (imported directly via `home-manager.users.${username} = import ./modules;` in `flake.nix`, no separate `home/home.nix`)

## Key Module Directories (modules/)
- `aerospace/` — window manager
- `catppuccin/` — theme (flavor: macchiato), one `catppuccin.<app>.enable` line per themed program
- `ghost/` — Ghostty face shader driven by herdr AI state (background in the separate Claude auto-memory system's `ghost-in-the-machine` note, not a Serena memory)
- `git/` — git config (hostname-conditional user.name)
- `llm-agents/` — AI tools (claude-code, opencode, beads, beads-viewer, gitnexus, herdr, hunk, rtk, serena, fff-mcp) via flake inputs
- `nixvim/` — Neovim via nixvim flake (plugins/, docs/, autocmds.nix, keymaps.nix, options.nix) — NOT LazyVim
- `presenterm/` — presentation tool + mermaid-cli
- `sketchybar/` — menu bar, Lua-based config (imported as `./sketchybar/config.nix`)
- `starship/` — shell prompt: `no-version.nix` (active, imported in modules/default.nix) + `powerline.nix` (alternate, unused)
- `terminal/` — Ghostty + Kitty terminal configs (`ghostty.nix`, `kitty.nix`, `options.nix`, `shaders/`), selected via the `terminal` specialArg
- `hosts/` — host-specific home-manager config (`maclop.nix`, `worklop.nix`), imported as `./hosts/${hostname}.nix`

See `mem:tech_stack` for flake inputs and packages. See `mem:conventions` for code style. See `mem:suggested_commands` for CLI usage. See `mem:task_completion` for task checklist.
