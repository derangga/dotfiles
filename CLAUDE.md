
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
├── flake.nix              # Main system configuration entry point
├── darwin/               # System-level configuration
├── home/                 # Home-manager configuration
└── modules/              # Modular configuration components
    ├── hosts/            # User-specific configurations
    ├── aerospace/        # Window manager configuration
    ├── catppuccin/       # Theme configuration
    ├── lazyvim/          # Neovim configuration
    ├── sketchybar/       # Menu bar configuration
    └── starship/         # Shell prompt configuration
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
- Host-specific configurations go in `modules/hosts/{username}.nix`
- Shared configurations use the `modules/default.nix` pattern
- Use relative imports with `./` syntax for local modules

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
- **Editor**: Neovim with LazyVim configuration
- **Git**: lazygit for interface
- **Shell**: Zsh with Oh My Zsh
- **File management**: yazi, eza, fzf

## Testing Strategy

- Configuration validity is tested by successful system rebuild
- No unit tests - this is declarative infrastructure
- Manual testing required for UI components (sketchybar, aerospace)
- Use `darwin-rebuild check` for syntax validation before deployment

## Serena MCP Usage

Serena is available as an MCP server providing semantic code tools. Prefer Serena's tools over raw file reads for codebase exploration.

### Rules
- **Always onboard Serena** at the start of a new conversation with `mcp__serena__onboarding` if not yet done
- **Use `get_symbols_overview`** to explore a file's structure before reading entire files
- **Use `find_symbol`** to locate specific functions, options, or attributes by name
- **Use `search_for_pattern`** when symbol names are uncertain or partial
- **Use `list_dir`** for directory exploration instead of shell `ls`
- **Read symbol bodies only when necessary** — avoid loading entire files unless no other option exists
- **Write memories** with `write_memory` when you discover non-obvious project facts worth retaining across sessions
- Serena memory files live in `.serena/` — do not edit them manually

## Important Notes

- This is a declarative Nix Darwin system - all changes must be made through Nix
- Manual edits to system files will be overwritten on next rebuild
- Always backup before major changes
- User configurations are in `modules/hosts/{username}.nix`
- System-wide configurations are in `darwin/configuration.nix`
