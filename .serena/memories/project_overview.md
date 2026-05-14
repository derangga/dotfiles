# Project Overview

A **nix-darwin** system configuration flake for macOS, managing two machines:
- `maclop` — personal laptop (username: `derangga`)
- `worklop` — work laptop (username: `sociolla`)

## Tech Stack
- **Nix Flakes** with `nix-darwin` for system-level macOS management
- **home-manager** for user-level dotfiles/programs
- **nix-homebrew** for Homebrew integration
- **catppuccin/nix** for theming (flavor: macchiato)
- Target: `aarch64-darwin` (Apple Silicon)

## Key Inputs
- `nixpkgs-unstable` channel
- `nix-darwin` (master branch)
- `home-manager`
- `catppuccin`
- `nix-homebrew`
