# Project Overview

Nix Darwin dotfiles repo for macOS system configuration using nix-darwin + home-manager.

## Tech Stack
- Nix (flakes), nix-darwin, home-manager, nix-homebrew
- Catppuccin theming across all tools
- LazyVim (Neovim) with Lua plugin configs
- Sketchybar (menu bar), Aerospace (window manager), Kitty/Ghostty (terminals)

## Key Commands
- Build & switch: `sudo darwin-rebuild switch --flake ~/nix#{hostname}`
- Check syntax: `sudo darwin-rebuild check --flake ~/nix#{hostname}`
- Build only: `sudo darwin-rebuild build --flake ~/nix#{hostname}`
- Format: `nixfmt file.nix`
- Garbage collect: `nix-collect-garbage -d`
- Aliases: `drb` (rebuild switch), `ngc` (garbage collect), `lg` (lazygit)

## Hosts
- `maclop` → user `derangga` (personal laptop)
- `worklop` → user `sociolla` (work laptop)

## Structure
- `flake.nix` — entry point, defines darwinConfigurations per host
- `darwin/` — system-level config (configuration.nix, terminal.nix, homebrew/)
- `home/home.nix` — home-manager entry
- `modules/default.nix` — shared programs config
- `modules/hosts/{hostname}.nix` — per-host user config
- `modules/` subdirs — per-tool configs (aerospace, catppuccin, git, lazyvim, sketchybar, starship, terminal)
