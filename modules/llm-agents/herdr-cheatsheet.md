# Herdr Cheatsheet

Reflects the keymap configured in `default.nix`. All bindings are pressed
**after the prefix** unless noted.

**Prefix**: `ctrl+b`

## Workspace

| Key       | Action            |
| --------- | ----------------- |
| `n`       | New workspace     |
| `shift+n` | Rename workspace  |
| `shift+d` | Close workspace   |

## Tab

| Key | Action         |
| --- | -------------- |
| `c` | New tab        |
| `,` | Rename tab     |
| `shift+w` | Close tab      |

## Pane / Split

| Key | Action          |
| --- | --------------- |
| `v` | Split vertical  |
| `-` | Split horizontal |
| `x` | Close pane      |
| `p` | Rename pane     |

## Navigation (vim-style)

| Key | Action            |
| --- | ----------------- |
| `h` | Focus pane left   |
| `j` | Focus pane down   |
| `k` | Focus pane up     |
| `l` | Focus pane right  |

## View

| Key | Action            |
| --- | ----------------- |
| `z` | Zoom (tmux-style) |
| `r` | Resize mode       |
| `b` | Toggle sidebar    |
| `e` | Edit scrollback   |

## Indexed Jumps

| Combo               | Action         |
| ------------------- | -------------- |
| `ctrl+1` … `ctrl+9` | Jump to tab N  |

## Unset by Default (available to bind)

`q` detach · `R` reload config · `o` open notification target ·
`H`/`L` prev/next workspace · `A`/`D` prev/next agent · `J`/`K` prev/next tab

## Config

- Path: `~/.config/herdr/config.toml` (managed by home-manager via `default.nix`)
- Dump defaults: `herdr --default-config`
- Docs: <https://herdr.dev/docs/configuration/>
