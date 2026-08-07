# Tech Stack

## Flake Inputs
- `nixpkgs` → `nixpkgs-unstable`
- `nix-darwin` → master branch
- `nix-homebrew` — Homebrew integration
- `home-manager` (follows nixpkgs)
- `catppuccin/nix` (follows nixpkgs)
- `nixvim` — Neovim configured entirely in Nix (follows nixpkgs)
- `fff-nvim` — `github:dmtrKovalenko/fff.nvim`, only its `fff-mcp` package is used (follows nixpkgs)
- `llm-agents` → `github:numtide/llm-agents.nix` (follows nixpkgs)
- `serena` → `git+https://github.com/oraios/serena` (follows nixpkgs)

## System Packages (darwin/configuration.nix)
ffmpeg, gnupg, mkalias, tree
(bun, cargo, fnm, go, orbstack, rust-analyzer, rustc live in `modules/default.nix` `home.packages`, not here)

## Home-manager Programs (modules/default.nix, shared)
atuin (replaced fzf — shell history/Ctrl-R search), bat, btop, eza, gh, gh-dash, lazygit, tmux, vscode, yazi, zoxide, zsh (Oh-My-Zsh, `git` plugin only)
Plus `services.jankyborders` (window border styling).

## AI/LLM Tools (modules/llm-agents/default.nix)
`home.packages` sourced from `llm-agents.packages.${system}` and `serena.packages.${system}`, plus `fff-nvim.packages.${system}.fff-mcp`:
fff-mcp, beads, beads-viewer, claude-code, gitnexus, herdr, hunk, opencode, rtk, serena
Also writes `xdg.configFile` for `herdr/config.toml` and `hunk/config.toml`, and two `home.activation` scripts that patch `~/.claude.json` (fff MCP entry) and append the fff-usage line to `~/.claude/CLAUDE.md`.

## Target Platform
`aarch64-darwin` (Apple Silicon Macs)
