# Project Overview

This is a **nix-darwin system configuration** repository that manages macOS system setup declaratively using Nix flakes.

## Purpose
Manage macOS system configuration, user environments, and application installations for multiple machines/users through a single declarative codebase.

## Tech Stack
- **Nix Flakes** - package management and system configuration
- **nix-darwin** - macOS system management
- **home-manager** - user environment management
- **nix-homebrew** - Homebrew integration for casks/brews not in nixpkgs
- **catppuccin** - theming (Mocha variant)
- **Lua** - used for sketchybar and lazyvim plugin configurations

## Architecture
The flake defines a `mkDarwinConfig` helper that takes `{hostname, username}` and wires up:
1. `darwin/configuration.nix` - system-level packages, fonts, dock/menubar settings
2. `home-manager` - user-level config via `home/home.nix` → `modules/default.nix`
3. `nix-homebrew` - Homebrew casks and brews

Host-specific config is loaded dynamically via `${hostname}` interpolation:
- `modules/hosts/${hostname}.nix` - user-level packages per host
- `darwin/homebrew/hosts/${hostname}.nix` - host-specific homebrew packages

## Current Hosts
- **maclop** (username: derangga) - personal laptop
- **worklop** (username: sociolla) - work laptop

## Codebase Structure
```
flake.nix                    # Entry point, defines darwinConfigurations
darwin/
  configuration.nix          # System packages, fonts, defaults
  homebrew/
    default.nix              # Shared homebrew config
    hosts/{hostname}.nix     # Per-host homebrew
home/
  home.nix                   # Home-manager entry, imports modules
modules/
  default.nix                # Central module hub (zsh, programs, services)
  hosts/{hostname}.nix       # Per-host user packages
  aerospace/config.nix       # Window manager
  catppuccin/config.nix      # Theme
  ghostty/config.nix         # Terminal emulator
  lazyvim/config.nix         # Neovim (+ plugins/ dir with Lua configs)
  sketchybar/config.nix      # Menu bar (+ lua/ dir)
  starship/config.nix        # Shell prompt
```

## Platform
- macOS (aarch64-darwin / Apple Silicon)
