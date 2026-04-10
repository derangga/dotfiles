# Suggested Commands

## Nix Darwin
- `sudo darwin-rebuild switch --flake ~/nix#{hostname}` — apply system config (alias: `drb`)
- `sudo darwin-rebuild check --flake ~/nix#{hostname}` — validate syntax before applying
- `sudo darwin-rebuild build --flake ~/nix#{hostname}` — build without switching
- `nix-collect-garbage -d` — clean up old generations (alias: `ngc`)

## Formatting
- `nixfmt file.nix` — format a Nix file

## Git
- `git` / `lazygit` (`lg`) — version control

## Workflow
1. Edit Nix files
2. `nixfmt` format changed files
3. `darwin-rebuild check` to validate
4. `darwin-rebuild switch` to apply
