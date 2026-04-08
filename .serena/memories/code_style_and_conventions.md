# Code Style & Conventions

## Nix Style
- **Indentation**: 2 spaces
- **Line width**: 120 characters max
- **File naming**: kebab-case for directories, snake_case for Nix files where appropriate
- **Function parameters**: pattern matching `{ pkgs, ... }:` syntax
- **Imports**: listed at top using `imports = [ ... ];`

## Module Organization
- Each major tool has its own directory under `modules/`
- Host-specific configs: `modules/hosts/{username}.nix`
- Shared configs use `modules/default.nix` pattern
- Use relative imports: `./` syntax

## Common Patterns

### System Packages
```nix
environment.systemPackages = with pkgs; [
  package-name   # alphabetical ordering preferred
];
```

### Home Manager Programs
```nix
programs.program-name = {
  enable = true;
};
```

### User-Specific Config
```nix
{ pkgs, hostname, username, ... }: {
  home.packages = with pkgs; [ ];
}
```

## Commenting
- Minimal comments — Nix is self-documenting
- Add comments only for complex logic or workarounds
- No trailing comments unless explaining a specific line
