
# Overview

This file provides essential information for agentic coding agents working in this Nix Darwin configuration repository.

## Build/Lint/Test Commands

### Primary Commands
- **Build system**: `sudo darwin-rebuild switch --flake ~/nix#{hostname}`
- **Build without switching**: `sudo darwin-rebuild build --flake ~/nix#{hostname}`
- **Check configuration**: `sudo darwin-rebuild check --flake ~/nix#{hostname}`
- **Garbage collection**: `nix-collect-garbage -d`

### Common Aliases (defined in user configs)
- `drb`: Shortcut for `sudo darwin-rebuild switch --flake ~/nix#{hostname}`
- `ngc`: Shortcut for `nix-collect-garbage -d`
- `lg`: `lazygit`

### Nix Formatting
- **Format Nix files**: `nixfmt file.nix` (nixfmt is included in neovim extra packages)
- **No explicit test framework**: This is a declarative configuration, tested by successful system rebuild

## Project Structure

```
nix/
├── flake.nix              # Thin: evaluates den.nix, re-exports den.flake.darwinConfigurations
├── den.nix                # den entities and aspects: hosts, users, per-user config
├── darwin/                # System-level configuration
│   └── homebrew/          # Homebrew integration (shared taps, brews, casks)
└── modules/               # Home-manager configuration (imported by den.schema.user.includes)
    ├── aerospace/         # Window manager configuration
    ├── catppuccin/        # Theme configuration
    ├── git/               # Git configuration
    ├── llm-agents/        # LLM agent tooling
    ├── nixvim/            # Neovim configuration (nixvim-based)
    │   ├── plugins/       # Plugin configurations (completion, lsp, etc.)
    │   └── docs/          # Neovim docs
    ├── presenterm/        # Terminal presentation tool
    ├── sketchybar/        # Menu bar configuration
    ├── starship/          # Shell prompt configuration
    └── terminal/          # Terminal configuration
```

## Code Style Guidelines

### Nix Configuration Style
- **Indentation**: 2 spaces (consistent with stylua.toml)
- **Line width**: 120 characters maximum
- **File naming**: kebab-case for directories, snake_case for Nix files where appropriate
- **Function parameters**: Use pattern matching with `{ pkgs, ... }:` syntax
- **Imports**: List all imports at the top of files using the `imports = [ ... ];` pattern

### Module Organization
- Each major tool/program has its own directory under `modules/`
- Host and user specific configuration goes in `den.nix` as a den aspect named after the host or user
- Shared configurations use the `modules/default.nix` pattern (the home-manager entry point)
- Use relative imports with `./` syntax for local modules

### den
The flake builds through [den](https://github.com/denful/den), pinned to `v0.18.0`. Three things to know before editing `den.nix`:
- den calls `instantiate` with `{ modules = [ ... ]; }` and no `specialArgs`. The `mkDarwin` override in `den.nix` re-adds `self`, `hostname`, `username` and `terminal`, and points at the `nix-darwin` input rather than the `darwin` name den defaults to
- `useGlobalPkgs` and `useUserPackages` default to `false` in den and are set explicitly in `den.schema.host.includes`. Removing them makes home-manager build its own nixpkgs, silently
- The `user-shell` and `hostname` batteries are deliberately unused. At v0.18.0 `user-shell` omits `environment.shells` on darwin, and `hostname` would start managing a machine name nothing managed before

### Configuration Patterns

#### System Packages
```nix
environment.systemPackages = with pkgs; [
  package-name
  # Alphabetical ordering preferred
];
```

#### Home Manager Programs
```nix
programs.program-name = {
  enable = true;
  # Program-specific configuration
};
```

#### User-Specific Configurations
```nix
{
  pkgs,
  hostname,
  username,
  ...
}: {
  home.packages = with pkgs; [ ];
  # User configuration here
}
```

### Import Patterns
- Always include required parameters explicitly: `{ pkgs, hostname, username, ... }`
- Use `...` ellipsis for unused arguments
- Forward `self`, `hostname`, `username`, `catppuccin`, `modulesDir` as needed

### Error Handling
- Nix configurations fail fast - syntax errors prevent rebuild
- Test changes with `darwin-rebuild check` before applying
- Use `nix-collect-garbage -d` to clean up failed builds

### File Organization
- Configuration files use kebab-case naming (e.g., `configuration.nix`, `home.nix`)
- Plugin configurations sourced as directories: `source = ./plugins; recursive = true;`
- Use `xdg.configFile` for dotfiles that don't have Nix options

### Variable Naming
- Use descriptive names: `hostname`, `username`, `modulesDir`
- Consistent with flake inputs: `nixpkgs`, `nix-darwin`, `home-manager`
- Follow Nix conventions for built-in names

### Commenting Style
- Minimal comments - Nix is self-documenting
- Add comments only for complex logic or workarounds
- No trailing comments unless explaining a specific line

## Development Workflow

1. **Make changes** to relevant Nix files
2. **Check syntax**: `sudo darwin-rebuild check --flake ~/nix#{hostname}`
3. **Test build**: `sudo darwin-rebuild build --flake ~/nix#{hostname}`
4. **Apply changes**: `sudo darwin-rebuild switch --flake ~/nix#{hostname}`

## Tools and Dependencies

### Essential Tools
- **nixfmt**: Nix code formatting
- **nix-darwin**: macOS system management
- **home-manager**: User environment management
- **nix-homebrew**: Homebrew integration

### Development Environment
- **Editor**: Neovim configured via nixvim (declarative Nix; see `modules/nixvim/`)
- **Git**: lazygit for interface
- **Shell**: Fish
- **File management**: yazi, eza, fzf

## Testing Strategy

- Configuration validity is tested by successful system rebuild
- No unit tests - this is declarative infrastructure
- Manual testing required for UI components (sketchybar, aerospace)
- Use `darwin-rebuild check` for syntax validation before deployment

## Important Notes

- This is a declarative Nix Darwin system - all changes must be made through Nix
- Manual edits to system files will be overwritten on next rebuild
- Always backup before major changes
- Per-user configuration is in `den.nix` under `den.aspects.{username}`, covering both the system and home-manager halves
- Shared home-manager configuration is in `modules/`
- System-wide configurations are in `darwin/configuration.nix`
- A new directory under `modules/` must be added to the `imports` list in `modules/default.nix`; a new host or user is added in `den.nix`
