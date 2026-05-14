# Suggested Commands

## Apply Configuration
```bash
sudo darwin-rebuild switch --flake ~/nix#maclop   # personal machine
sudo darwin-rebuild switch --flake ~/nix#worklop  # work machine
# alias: drb  (picks up hostname automatically via shellAlias)
```

## Validate Without Applying
```bash
sudo darwin-rebuild check --flake ~/nix#<hostname>
sudo darwin-rebuild build --flake ~/nix#<hostname>
```

## Nix Maintenance
```bash
nix-collect-garbage -d   # alias: ngc
nix flake update         # update all flake inputs
nix flake lock --update-input <input>  # update single input
```

## Formatting
```bash
nixfmt <file.nix>        # format a single Nix file (nixfmt included in system packages via neovim extras)
```

## Utilities
```bash
lazygit   # alias: lg
brew services start aerogesture   # alias: agc
```

## Notes
- Do NOT run `darwin-rebuild` directly — requires sudo; user must run it themselves.
- No unit test framework — successful rebuild IS the test.
- `darwin-rebuild check` is safe for syntax validation without side effects.
