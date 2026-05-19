# Suggested Commands

## Apply Configuration
```bash
sudo darwin-rebuild switch --flake ~/nix#maclop   # personal machine
sudo darwin-rebuild switch --flake ~/nix#worklop  # work machine
# alias: drb  (hostname-aware via shellAlias)
```

## Validate Without Applying
```bash
sudo darwin-rebuild check --flake ~/nix#<hostname>   # syntax check, no side effects
sudo darwin-rebuild build --flake ~/nix#<hostname>   # full build, no switch
```

## Nix Maintenance
```bash
nix-collect-garbage -d     # alias: ngc
nix flake update           # update all flake inputs
nix flake lock --update-input <input>   # update single input
```

## Formatting
```bash
nixfmt <file.nix>   # nixfmt available via nixvim extraPackages
```

## Utilities
```bash
lazygit              # alias: lg
brew services start aerogesture   # alias: agstart
brew services stop aerogesture    # alias: agstop
brew services restart aerogesture # alias: agrestart
```

## Notes
- Do NOT run `darwin-rebuild` yourself — requires sudo; instruct user to run it.
- No unit test framework — successful rebuild IS the test.
- Lua files (sketchybar, nixvim) are symlinked at build time; no rebuild needed for their edits if already built.
