# Tech Stack

## Flake Inputs
- `nixpkgs` → `nixpkgs-unstable`
- `nix-darwin` → master branch
- `home-manager` (follows nixpkgs)
- `catppuccin/nix` (follows nixpkgs)
- `nix-homebrew` — Homebrew integration
- `nixvim` — Neovim configured entirely in Nix
- `fff-nvim` — Neovim plugin (custom flake input)
- `llm-agents` → `github:numtide/llm-agents.nix` — provides claude-code, opencode, beads, rtk
- `serena` → `git+https://github.com/oraios/serena` — MCP server for semantic code tools

## System Packages (darwin/configuration.nix)
bun, cargo, fnm, ffmpeg, gnupg, go, mkalias, nixd, pnpm, rustc, rust-analyzer, tree, uv

## Home-manager Programs (modules/default.nix, shared)
bat, btop, eza, fzf, gh, gh-dash, lazygit, tmux, yazi, zed-editor (package=null), zoxide, zsh (Oh-My-Zsh)

## AI/LLM Tools (modules/llm-agents/default.nix)
Sourced from `llm-agents.packages.${system}` and `serena.packages.${system}`:
claude-code, opencode, beads, rtk, serena

## Target Platform
`aarch64-darwin` (Apple Silicon Macs)
