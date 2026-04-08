# Project Overview

## Purpose
Nix Darwin system configuration for macOS machines. Manages system-level and user-level configuration declaratively using Nix flakes.

## Hosts
- `maclop` — personal laptop, username: `derangga`
- `worklop` — work laptop, username: `sociolla`

## Tech Stack
- **Nix flakes** — package management and system configuration
- **nix-darwin** — macOS system management
- **home-manager** — user environment management
- **nix-homebrew** — Homebrew integration via Nix
- **catppuccin** — theming

## Key Inputs (flake.nix)
- `nixpkgs` (unstable)
- `nix-darwin`
- `home-manager`
- `nix-homebrew`
- `catppuccin`
