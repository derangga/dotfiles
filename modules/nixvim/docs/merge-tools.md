# Resolving Merge Conflicts with diffview.nvim

> A step-by-step guide to resolving Git merge conflicts inside Neovim using [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) — a VSCode-like conflict resolution experience, right in your terminal.

---

## Step 1 — Trigger the Merge Conflict View

While your repo is in a conflicted state (mid-merge or mid-rebase), simply run:

```vim
:DiffviewOpen
```

Diffview will detect the conflict state automatically and list all conflicted files in their own dedicated section in the file panel.

---

## Step 2 — Understand the 3-Way Layout

Conflicted files open in a **3-way split** by default:

| Pane | Description |
|------|-------------|
| **Left (OURS)** | Your current branch's version |
| **Middle (Result)** | The file you edit — this is the final output |
| **Right (THEIRS)** | The incoming branch's version |

The file panel shows the **remaining conflict count** next to each filename, so you can track your progress across multiple files.

> **Tip:** Press `g<C-x>` to cycle through available layouts (e.g. `diff3_mixed`, `diff4_mixed`) if you prefer a different split arrangement.

---

## Step 3 — Navigate Between Conflicts

Use these keymaps to jump between conflict markers within a file:

| Key | Action |
|-----|--------|
| `]x` | Go to the **next** conflict |
| `[x` | Go to the **previous** conflict |

---

## Step 4 — Resolve Each Conflict

With your cursor on a conflict in the **middle (result) buffer**, choose how to resolve it:

### Per-Conflict Keymaps

| Key | Action |
|-----|--------|
| `<leader>co` | Keep **OURS** (current branch) |
| `<leader>ct` | Keep **THEIRS** (incoming branch) |
| `<leader>cb` | Keep **BASE** (common ancestor) |
| `<leader>ca` | Keep **ALL** versions (concatenated) |
| `dx` | **Delete** the conflict region |

### Whole-File Keymaps (from the File Panel)

| Key | Action |
|-----|--------|
| `<leader>cO` | Accept OURS for the whole file |
| `<leader>cT` | Accept THEIRS for the whole file |
| `<leader>cB` | Accept BASE for the whole file |
| `<leader>cA` | Accept ALL versions for the whole file |
| `dX` | Delete all conflict regions in the file |

---

## Step 5 — Manual Edits (Optional)

You can freely edit the **middle buffer** directly — just type in it like a normal Neovim buffer. This is useful when neither OURS nor THEIRS is exactly right and you need to craft a custom resolution by hand.

---

## Step 6 — Mark as Resolved & Finalize

1. **Save the file** after resolving all its conflicts:
   ```vim
   :w
   ```
   The conflict count next to the filename will drop to `0` and the file moves out of the "Conflicted" section.

2. **Repeat** for all conflicted files.

3. **Close diffview** when done:
   ```vim
   :DiffviewClose
   ```

4. **Complete the merge or rebase** in your terminal:
   ```bash
   git merge --continue
   # or
   git rebase --continue
   ```

---

## Quick Reference Cheatsheet

```
:DiffviewOpen          → Open conflict view during merge/rebase
:DiffviewClose         → Close the view

]x / [x                → Next / previous conflict
g<C-x>                 → Cycle layouts

<leader>co             → Choose OURS
<leader>ct             → Choose THEIRS
<leader>cb             → Choose BASE
<leader>ca             → Choose ALL
dx                     → Delete conflict region

<leader>cO/T/B/A       → Apply choice to WHOLE FILE
dX                     → Delete ALL conflicts in file
```
