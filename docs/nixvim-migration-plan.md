# Nixvim Migration Plan

## Goal

Rewrite the current LazyVim-based Neovim configuration into a standalone **Nixvim** configuration.
The Nixvim setup must replicate the same keymaps, options, autocmds, and core plugin behavior
as LazyVim + user customizations, but managed entirely through Nix.

Scope: **core functionality + keymaps only** (no extras/lang packs for now).

### Source Directories

- **`others/lazyvim/`** — Original LazyVim source code cloned from the LazyVim GitHub repository.
  This is the reference for all default behavior (keymaps, options, autocmds, plugin specs).
- **`modules/lazyvim/`** — User's personal LazyVim installation/configuration.
  Contains `config.nix` (home-manager module) and `plugins/` (the `~/.config/nvim` content
  with custom keymaps, plugin overrides, LSP servers, colorscheme, etc.).

The Nixvim config must replicate the **combined behavior** of both: LazyVim defaults + user overrides.

---

## Architecture Overview

### Current Setup (LazyVim)

```
modules/lazyvim/
  config.nix              -> home-manager module, symlinks plugins/ to ~/.config/nvim
  plugins/
    init.lua              -> bootstraps lazy.nvim
    lua/config/           -> lazy.lua, options.lua, keymaps.lua, autocmds.lua
    lua/plugins/          -> 15 plugin spec files (Lua)
```

- Plugin management: **lazy.nvim** (runtime download + lazy-loading)
- LSP tooling install: **mason.nvim** (runtime download)
- All config in Lua

### Target Setup (Nixvim)

```
modules/nixvim/
  default.nix             -> standalone Nixvim flake module
  config/
    options.nix           -> vim options
    keymaps.nix           -> all keymaps (lazyvim defaults + user custom)
    autocmds.nix          -> autocommands
  plugins/
    ui.nix                -> bufferline, lualine, noice, mini-icons, dashboard
    explorer.nix          -> neo-tree (file explorer sidebar)
    editor.nix            -> flash, which-key, gitsigns, trouble, todo-comments, grug-far
    coding.nix            -> mini-pairs, mini-ai, ts-comments, autopairs/autotag
    treesitter.nix        -> treesitter + textobjects
    lsp.nix               -> lspconfig (servers declared in Nix, no mason)
    formatting.nix        -> conform.nvim
    linting.nix           -> nvim-lint
    colorscheme.nix       -> catppuccin
    snacks.nix            -> snacks.nvim (bigfile, quickfile, terminal, dashboard, indent, etc.)
    persistence.nix       -> session management
    extras.nix            -> smear-cursor, tmux-navigator, render-markdown
```

- Plugin management: **Nix** (plugins installed at build time, no lazy.nvim)
- LSP servers: **Nix packages** (no mason)
- All config in Nix (with `extraConfigLua` escape hatch where needed)

---

## Phase 1: Scaffold & Options

### 1.1 Create standalone Nixvim flake module

- Add `nixvim` as a flake input in `flake.nix`
- Create `modules/nixvim/default.nix` as the entry point
- Import all sub-modules from `config/` and `plugins/`
- Wire it into home-manager via `programs.nixvim.enable = true`

### 1.2 Vim Options (`config/options.nix`)

Translate all options from:
- LazyVim source: `others/lazyvim/lua/lazyvim/config/options.lua`
- User config: `modules/lazyvim/plugins/lua/config/options.lua` (no custom overrides, uses LazyVim defaults)

| LazyVim Option | Nixvim Setting |
|---|---|
| `vim.g.mapleader = " "` | `globals.mapleader = " "` |
| `vim.g.maplocalleader = "\\"` | `globals.maplocalleader = "\\"` |
| `vim.g.autoformat = true` | `globals.autoformat = true` |
| `opt.autowrite = true` | `opts.autowrite = true` |
| `opt.clipboard = "unnamedplus"` | `clipboard.register = "unnamedplus"` |
| `opt.completeopt = "menu,menuone,noselect"` | `opts.completeopt = "menu,menuone,noselect"` |
| `opt.conceallevel = 2` | `opts.conceallevel = 2` |
| `opt.confirm = true` | `opts.confirm = true` |
| `opt.cursorline = true` | `opts.cursorline = true` |
| `opt.expandtab = true` | `opts.expandtab = true` |
| `opt.foldlevel = 99` | `opts.foldlevel = 99` |
| `opt.grepprg = "rg --vimgrep"` | `opts.grepprg = "rg --vimgrep"` |
| `opt.ignorecase = true` | `opts.ignorecase = true` |
| `opt.inccommand = "nosplit"` | `opts.inccommand = "nosplit"` |
| `opt.laststatus = 3` | `opts.laststatus = 3` |
| `opt.list = true` | `opts.list = true` |
| `opt.mouse = "a"` | `opts.mouse = "a"` |
| `opt.number = true` | `opts.number = true` |
| `opt.relativenumber = true` | `opts.relativenumber = true` |
| `opt.scrolloff = 4` | `opts.scrolloff = 4` |
| `opt.shiftround = true` | `opts.shiftround = true` |
| `opt.shiftwidth = 2` | `opts.shiftwidth = 2` |
| `opt.showmode = false` | `opts.showmode = false` |
| `opt.sidescrolloff = 8` | `opts.sidescrolloff = 8` |
| `opt.signcolumn = "yes"` | `opts.signcolumn = "yes"` |
| `opt.smartcase = true` | `opts.smartcase = true` |
| `opt.smartindent = true` | `opts.smartindent = true` |
| `opt.smoothscroll = true` | `opts.smoothscroll = true` |
| `opt.splitbelow = true` | `opts.splitbelow = true` |
| `opt.splitright = true` | `opts.splitright = true` |
| `opt.tabstop = 2` | `opts.tabstop = 2` |
| `opt.termguicolors = true` | `opts.termguicolors = true` |
| `opt.timeoutlen = 300` | `opts.timeoutlen = 300` |
| `opt.undofile = true` | `opts.undofile = true` |
| `opt.undolevels = 10000` | `opts.undolevels = 10000` |
| `opt.updatetime = 200` | `opts.updatetime = 200` |
| `opt.virtualedit = "block"` | `opts.virtualedit = "block"` |
| `opt.wrap = false` | `opts.wrap = false` |
| `opt.linebreak = true` | `opts.linebreak = true` |
| `opt.pumblend = 10` | `opts.pumblend = 10` |
| `opt.pumheight = 10` | `opts.pumheight = 10` |
| `opt.ruler = false` | `opts.ruler = false` |
| `opt.splitkeep = "screen"` | `opts.splitkeep = "screen"` |
| `opt.winminwidth = 5` | `opts.winminwidth = 5` |

Additional globals:
- `vim.g.markdown_recommended_style = 0`

---

## Phase 2: Keymaps (`config/keymaps.nix`)

This is the most critical section. All keymaps from three sources must be merged:

### 2.1 LazyVim Core Keymaps (from `others/lazyvim/lua/lazyvim/config/keymaps.lua`)

```
# Better up/down (visual lines)
j / k             -> gj / gk (expr, when no count)

# Window navigation
<C-h/j/k/l>       -> <C-w>h/j/k/l (NOTE: user overrides with tmux-navigator)

# Resize windows
<C-Up/Down>        -> resize +/-2
<C-Left/Right>     -> vertical resize -/+2

# Move lines
<A-j/k>            -> move line down/up (normal, insert, visual)

# Buffers
<S-h>              -> BufferLineCyclePrev (via bufferline plugin)
<S-l>              -> BufferLineCycleNext (via bufferline plugin)
[b / ]b            -> BufferLineCyclePrev / BufferLineCycleNext
<leader>bb         -> switch to other buffer (e #)
<leader>`          -> switch to other buffer (e #)
<leader>bd         -> Snacks.bufdelete()
<leader>bo         -> Snacks.bufdelete.other()
<leader>bD         -> :bd (delete buffer and window)
<leader>bp         -> BufferLineTogglePin
<leader>bP         -> BufferLineGroupClose ungrouped
<leader>br         -> BufferLineCloseRight
<leader>bl         -> BufferLineCloseLeft
<leader>bj         -> BufferLinePick

# Escape clears search
<Esc>              -> noh + snippet stop

# Redraw
<leader>ur         -> nohlsearch + diffupdate + redraw

# Saner n/N
n / N              -> consistent forward/backward regardless of / or ?

# Undo break-points
, / . / ;          -> insert <c-g>u

# Save
<C-s>              -> :w (all modes)

# Keywordprg
<leader>K          -> K

# Better indenting
< / > (visual)     -> <gv / >gv (stay in visual)

# Commenting
gco                -> add comment below
gcO                -> add comment above

# New file
<leader>fn         -> :enew

# Location/quickfix list
<leader>xl         -> toggle location list
<leader>xq         -> toggle quickfix list
[q / ]q            -> cprev / cnext (or Trouble prev/next)

# Formatting
<leader>cf         -> format (LazyVim.format)

# Diagnostics
<leader>cd         -> vim.diagnostic.open_float
]d / [d            -> next/prev diagnostic
]e / [e            -> next/prev error
]w / [w            -> next/prev warning

# Toggle options (via Snacks.toggle, will need extraConfigLua)
<leader>uf         -> toggle autoformat (global)
<leader>uF         -> toggle autoformat (buffer)
<leader>us         -> toggle spelling
<leader>uw         -> toggle wrap
<leader>uL         -> toggle relative number
<leader>ud         -> toggle diagnostics
<leader>ul         -> toggle line numbers
<leader>uc         -> toggle conceal level
<leader>uA         -> toggle tabline
<leader>uT         -> toggle treesitter
<leader>ub         -> toggle dark/light background
<leader>uh         -> toggle inlay hints

# Lazygit
<leader>gg         -> Snacks.lazygit (root dir)
<leader>gG         -> Snacks.lazygit (cwd)
<leader>gL         -> git log (cwd)
<leader>gb         -> git blame line
<leader>gf         -> git current file history
<leader>gl         -> git log
<leader>gB         -> git browse (open)
<leader>gY         -> git browse (copy)

# Quit
<leader>qq         -> :qa

# Inspect
<leader>ui         -> vim.show_pos
<leader>uI         -> treesitter inspect tree

# Terminal
<leader>fT         -> Snacks.terminal (cwd)
<leader>ft         -> Snacks.terminal (root dir)
<c-/>              -> Snacks.terminal.focus (root dir)

# Windows
<leader>-          -> horizontal split
<leader>|          -> vertical split
<leader>wd         -> close window
<leader>wm         -> toggle zoom

# Tabs
<leader><tab>l     -> last tab
<leader><tab>o     -> close other tabs
<leader><tab>f     -> first tab
<leader><tab><tab> -> new tab
<leader><tab>]     -> next tab
<leader><tab>d     -> close tab
<leader><tab>[     -> previous tab

# Scratch/profiler (from others/lazyvim/lua/lazyvim/plugins/util.lua)
<leader>.          -> Snacks.scratch()
<leader>S          -> Snacks.scratch.select()
<leader>dps        -> Snacks.profiler.scratch()

# Session (persistence.nvim)
<leader>qs         -> restore session
<leader>qS         -> select session
<leader>ql         -> restore last session
<leader>qd         -> stop session save
```

### 2.2 LazyVim LSP Keymaps (from `others/lazyvim/lua/lazyvim/plugins/lsp/init.lua`)

These are buffer-local, attached when LSP connects:

```
<leader>cl         -> Lsp Info (Snacks.picker.lsp_config)
gd                 -> goto definition
gr                 -> references
gI                 -> goto implementation
gy                 -> goto type definition
gD                 -> goto declaration
K                  -> hover
gK                 -> signature help
<c-k> (insert)     -> signature help
<leader>ca         -> code action
<leader>cc         -> run codelens
<leader>cC         -> refresh codelens
<leader>cR         -> rename file
<leader>cr         -> rename symbol
<leader>cA         -> source action
<leader>co         -> organize imports
]] / [[            -> next/prev reference (word highlight)
<a-n> / <a-p>      -> next/prev reference (wrap)
```

### 2.3 Plugin-specific Keymaps (from `others/lazyvim/lua/lazyvim/plugins/*.lua` + user's `modules/lazyvim/plugins/lua/plugins/*.lua`)

```
# Neo-tree (file explorer)
<leader>fe         -> toggle neo-tree (root dir)
<leader>fE         -> toggle neo-tree (cwd)
<leader>e          -> remap to <leader>fe (explorer root dir)
<leader>E          -> remap to <leader>fE (explorer cwd)
<leader>ge         -> git status explorer
<leader>be         -> buffer explorer

# Flash (editor.lua)
s                  -> Flash jump
S                  -> Flash treesitter
r (operator)       -> remote flash
R (operator/visual)-> treesitter search
<c-s> (cmdline)    -> toggle flash search
<c-space>          -> treesitter incremental selection

# Which-key
<leader>?          -> buffer keymaps
<c-w><space>       -> window hydra mode

# Gitsigns (buffer-local on attach)
]h / [h            -> next/prev hunk
]H / [H            -> last/first hunk
<leader>ghs        -> stage hunk
<leader>ghr        -> reset hunk
<leader>ghS        -> stage buffer
<leader>ghu        -> undo stage hunk
<leader>ghR        -> reset buffer
<leader>ghp        -> preview hunk inline
<leader>ghb        -> blame line
<leader>ghB        -> blame buffer
<leader>ghd        -> diff this
<leader>ghD        -> diff this ~
ih (textobj)       -> select hunk

# Trouble
<leader>xx         -> diagnostics toggle
<leader>xX         -> buffer diagnostics toggle
<leader>cs         -> symbols toggle
<leader>cS         -> LSP refs/defs toggle
<leader>xL         -> location list toggle
<leader>xQ         -> quickfix list toggle

# Todo-comments
]t / [t            -> next/prev todo
<leader>xt         -> todo (trouble)
<leader>xT         -> todo/fix/fixme (trouble)
<leader>st         -> todo (telescope/picker)
<leader>sT         -> todo/fix/fixme (telescope/picker)

# Bufferline
(see buffer keymaps above - <S-h>, <S-l>, [b, ]b, etc.)
[B / ]B            -> move buffer prev/next

# Noice
<leader>sn         -> +noice group
<S-Enter>          -> redirect cmdline
<leader>snl        -> noice last message
<leader>snh        -> noice history
<leader>sna        -> noice all
<leader>snd        -> dismiss all
<leader>snt        -> noice picker
<c-f> / <c-b>      -> scroll forward/backward

# Snacks UI
<leader>n          -> notification history
<leader>un         -> dismiss all notifications

# Conform
<leader>cF         -> format injected langs

# NOTE: <leader>cm (Mason) is removed — no mason in Nixvim, LSP servers installed via Nix

# Tmux navigator (from user's modules/lazyvim/plugins/lua/plugins/tmux-navigator.lua, overrides <C-h/j/k/l>)
<c-h>              -> TmuxNavigateLeft
<c-j>              -> TmuxNavigateDown
<c-k>              -> TmuxNavigateUp
<c-l>              -> TmuxNavigateRight
<c-\>              -> TmuxNavigatePrevious
```

### 2.4 User Custom Keymaps (from `modules/lazyvim/plugins/lua/config/keymaps.lua`)

```
jk (insert)        -> <ESC>
<leader>/          -> toggle comment (gcc/gc)
<leader>tb         -> toggle git line blame
<Esc>b             -> vertical resize -2
<Esc>f             -> vertical resize +2
<M-Up>             -> resize +2
<M-Down>           -> resize -2
```

### 2.5 Nixvim Keymap Strategy

- Simple keymaps -> `keymaps = [ { key = ...; action = ...; mode = ...; options = { desc = ...; }; } ]`
- Complex keymaps (Lua functions, Snacks calls) -> `extraConfigLua` blocks
- Plugin-specific keymaps -> configured within each plugin's Nixvim module
- LSP keymaps -> configured in `plugins.lsp.keymaps.lspBuf` or via `extraConfigLua`

---

## Phase 3: Autocmds (`config/autocmds.nix`)

Translate all autocmds from:
- LazyVim source: `others/lazyvim/lua/lazyvim/config/autocmds.lua`
- User config: `modules/lazyvim/plugins/lua/config/autocmds.lua`

| Autocmd | Events | Purpose |
|---|---|---|
| checktime | FocusGained, TermClose, TermLeave | Reload file if changed externally |
| highlight_yank | TextYankPost | Flash highlight on yank |
| resize_splits | VimResized | Equalize splits on resize |
| last_loc | BufReadPost | Jump to last cursor position |
| close_with_q | FileType (help, qf, etc.) | Close special buffers with q |
| man_unlisted | FileType (man) | Don't list man pages |
| wrap_spell | FileType (text, markdown, etc.) | Enable wrap + spell |
| json_conceal | FileType (json, jsonc, json5) | Set conceallevel=0 |
| auto_create_dir | BufWritePre | Create parent dirs on save |
| mdx_filetype | (user) | Register .mdx as markdown.mdx |
| smear_cursor | BufEnter (user) | Enable smear cursor on buffer enter |
| diagnostic_float | CursorHold (user) | Show diagnostic float on cursor hold |

---

## Phase 4: Core Plugins

### 4.1 Colorscheme (`plugins/colorscheme.nix`)

```nix
colorschemes.catppuccin = {
  enable = true;
  settings = {
    flavour = "macchiato";
    transparent_background = true;
    integrations = {
      # all the integrations from lazyvim's catppuccin config
      gitsigns = true;
      flash = true;
      which_key = true;
      noice = true;
      mini.enabled = true;
      snacks = true;
      treesitter_context = true;
      # etc.
    };
  };
};
```

### 4.2 Treesitter (`plugins/treesitter.nix`)

```nix
plugins.treesitter = {
  enable = true;
  settings = {
    highlight.enable = true;
    indent.enable = true;
  };
  grammarPackages = [
    # LazyVim defaults + user additions
    "bash" "c" "css" "diff" "go" "html" "javascript" "jsdoc" "json"
    "lua" "luadoc" "luap" "markdown" "markdown_inline" "nix" "printf"
    "python" "query" "regex" "toml" "tsx" "typescript" "vim" "vimdoc"
    "vue" "xml" "yaml"
  ];
};
plugins.treesitter-textobjects = {
  enable = true;
  # move keymaps: ]f, [f, ]c, [c, ]a, [a, etc.
};
```

### 4.3 LSP (`plugins/lsp.nix`)

No mason - all servers installed via Nix packages:

```nix
plugins.lsp = {
  enable = true;
  servers = {
    lua_ls.enable = true;
    bashls.enable = true;
    clangd.enable = true;
    cssls.enable = true;
    eslint.enable = true;
    gopls.enable = true;
    html.enable = true;
    jsonls.enable = true;
    marksman.enable = true;
    sqls.enable = true;
    tailwindcss.enable = true;
    ts_ls.enable = true;    # or vtsls
    vue_ls.enable = true;   # check nixvim support
    yamlls.enable = true;
  };
  # Diagnostic config
  # Inlay hints
  # LSP keymaps via onAttach or extraConfigLua
};
```

### 4.4 Formatting (`plugins/formatting.nix`)

```nix
plugins.conform-nvim = {
  enable = true;
  settings = {
    formatters_by_ft = {
      lua = ["stylua"];
      css = ["prettier"];
      html = ["prettier"];
      javascript = ["prettier"];
      javascriptreact = ["prettier"];
      json = ["prettier"];
      nix = ["nixfmt"];
      typescript = ["prettier"];
      typescriptreact = ["prettier"];
      vue = ["prettier"];
      fish = ["fish_indent"];
      sh = ["shfmt"];
    };
    default_format_opts = {
      timeout_ms = 3000;
      lsp_format = "fallback";
    };
  };
};
```

### 4.5 Linting (`plugins/linting.nix`)

```nix
plugins.lint = {
  enable = true;
  lintersByFt = {
    fish = ["fish"];
  };
  # autoCmd events: BufWritePost, BufReadPost, InsertLeave
};
```

### 4.6 UI Plugins (`plugins/ui.nix`)

- **bufferline**: `plugins.bufferline.enable = true;`
- **lualine**: `plugins.lualine.enable = true;` with custom separators
- **noice**: `plugins.noice.enable = true;` with lazyvim-matching config
- **mini.icons**: `plugins.mini.icons.enable = true;`
- **snacks dashboard**: via `extraConfigLua` or `plugins.snacks` (check nixvim support)

### 4.7 File Explorer (`plugins/explorer.nix`)

Neo-tree as the sidebar file explorer (LazyVim's default for older installs,
and a well-supported nixvim module):

```nix
plugins.neo-tree = {
  enable = true;
  sources = ["filesystem" "buffers" "git_status"];
  filesystem = {
    bindToCwd = false;
    followCurrentFile.enabled = true;
    useLibuvFileWatcher = true;
  };
  window.mappings = {
    "l" = "open";
    "h" = "close_node";
    "<space>" = "none";
    "P" = { command = "toggle_preview"; config.use_float = false; };
  };
  defaultComponentConfigs = {
    indent = {
      withExpanders = true;
      expanderCollapsed = "";
      expanderExpanded = "";
    };
    gitStatus.symbols = {
      unstaged = "󰄱";
      staged = "󰱒";
    };
  };
};
```

Keymaps:
```
<leader>fe         -> toggle neo-tree (root dir)
<leader>fE         -> toggle neo-tree (cwd)
<leader>e          -> remap to <leader>fe
<leader>E          -> remap to <leader>fE
<leader>ge         -> git status explorer
<leader>be         -> buffer explorer
```

### 4.8 Editor Plugins (`plugins/editor.nix`)

- **flash.nvim**: `plugins.flash.enable = true;` (check nixvim support, may need extraPlugins)
- **which-key**: `plugins.which-key.enable = true;` with group specs
- **gitsigns**: `plugins.gitsigns.enable = true;` with signs config + on_attach keymaps
- **trouble**: `plugins.trouble.enable = true;`
- **todo-comments**: `plugins.todo-comments.enable = true;`
- **grug-far**: likely needs `extraPlugins` (may not have nixvim module)

### 4.9 Coding Plugins (`plugins/coding.nix`)

- **mini.pairs**: `plugins.mini.pairs.enable = true;`
- **mini.ai**: `plugins.mini.ai.enable = true;`
- **ts-comments**: may need `extraPlugins`
- **nvim-ts-autotag**: `plugins.ts-autotag.enable = true;` with user's custom config

### 4.10 Snacks.nvim (`plugins/snacks.nix`)

Snacks is heavily used by LazyVim for:
- bigfile, quickfile
- terminal (with nav keymaps)
- dashboard (user's custom ASCII art)
- indent, input, notifier, scope, scroll, words
- bufdelete, lazygit, gitbrowse, scratch, profiler, picker
- toggle helpers

This will likely need `extraPlugins` + significant `extraConfigLua` since
snacks.nvim may not have a full Nixvim module.

### 4.11 Extra Plugins (`plugins/extras.nix`)

- **persistence.nvim**: session management with keymaps
- **smear-cursor**: `extraPlugins` + config
- **tmux-navigator**: `plugins.tmux-navigator.enable = true;` or `extraPlugins`
- **render-markdown**: for markdown rendering
- **plenary**: dependency (auto-pulled by Nix)

---

## Phase 5: Snacks.nvim Deep Integration

Snacks is the backbone of many LazyVim features. Since nixvim may not have
a native module for all snacks features, the strategy is:

1. Install snacks.nvim via `extraPlugins`
2. Configure via `extraConfigLua` with a `require("snacks").setup({...})` call
3. Map snacks-dependent keymaps in `extraConfigLua`
4. Features to configure:
   - `bigfile` (auto-disable features for large files)
   - `quickfile` (fast file open)
   - `terminal` (floating terminal with nav keys)
   - `dashboard` (custom ASCII art + pick actions)
   - `indent` (indent guides)
   - `input` (better vim.ui.input)
   - `notifier` (notification system)
   - `scope` (scope highlighting)
   - `scroll` (smooth scroll)
   - `words` (word highlighting + jump)
   - `toggle` (option toggles)
   - `bufdelete` (safe buffer deletion)
   - `lazygit` (lazygit integration)
   - `gitbrowse` (open in browser)
   - `scratch` (scratch buffers)
   - `profiler` (profiler UI)
   - `picker` (fuzzy finder - replaces telescope/fzf)
   - `rename` (file rename)
   - `zen` / `zoom` (focus modes)

---

## Phase 6: Integration & Wiring

### 6.1 Flake Input

```nix
# In flake.nix, add:
inputs.nixvim = {
  url = "github:nix-community/nixvim";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### 6.2 Home-Manager Integration

```nix
# In the home-manager module:
imports = [ inputs.nixvim.homeManagerModules.nixvim ];
# Then either:
programs.nixvim = { enable = true; /* ... */ };
# Or import modules/nixvim/default.nix
```

### 6.3 Extra Packages

These were in the old `config.nix` and still needed:
- `fd` (finder)
- `gcc` (treesitter compilation)
- `lua` (lua runtime)
- `nixfmt` (nix formatting)
- `ripgrep` (grep)
- `lazygit` (git UI)
- `prettier` (web formatting) - via Nix, not mason
- `stylua` (lua formatting) - via Nix, not mason

---

## Implementation Order

1. **Scaffold**: Create `modules/nixvim/default.nix`, add nixvim flake input
2. **Options**: `config/options.nix` - straightforward 1:1 translation
3. **Colorscheme**: `plugins/colorscheme.nix` - catppuccin macchiato
4. **Treesitter**: `plugins/treesitter.nix` - grammars + textobjects
5. **LSP**: `plugins/lsp.nix` - all servers, diagnostics config
6. **Formatting**: `plugins/formatting.nix` - conform.nvim
7. **Linting**: `plugins/linting.nix` - nvim-lint
8. **Explorer**: `plugins/explorer.nix` - neo-tree file explorer sidebar
9. **Editor**: `plugins/editor.nix` - flash, which-key, gitsigns, trouble, todo-comments
10. **UI**: `plugins/ui.nix` - bufferline, lualine, noice
11. **Coding**: `plugins/coding.nix` - mini.pairs, mini.ai, autotag
12. **Snacks**: `plugins/snacks.nix` - the big one, likely heavy extraConfigLua
13. **Extras**: `plugins/extras.nix` - smear-cursor, tmux-nav, render-markdown, persistence
14. **Keymaps**: `config/keymaps.nix` - all keymaps (depends on plugins being set up)
15. **Autocmds**: `config/autocmds.nix` - all autocommands
16. **Test & iterate**: Build, verify keymaps work, fix issues

---

## Key Risks & Decisions

| Risk | Mitigation |
|---|---|
| snacks.nvim has no nixvim module | Use `extraPlugins` + `extraConfigLua` |
| Some plugins lack nixvim modules | Use `extraPlugins` with `pkgs.vimPlugins.*` or `fetchFromGitHub` |
| Complex Lua keymaps (closures, conditionals) | Use `extraConfigLua` for these, simple ones in `keymaps` |
| LazyVim utility functions (LazyVim.format, etc.) not available | Reimplement needed utilities or use plugin APIs directly |
| Lazy-loading behavior differences | Nixvim loads all plugins at startup; accept slightly slower startup or use `event`/`cmd` loading where nixvim supports it |
| Mason-installed tools vs Nix packages | All tools via Nix `extraPackages`; may need to verify binary names match |

---

## What's NOT in Scope (for now)

- LazyVim extras (lang packs, AI integrations, DAP, etc.)
- Completion engine (blink.cmp / nvim-cmp) - will be a follow-up
- Fuzzy picker details (snacks_picker) - basic setup only
- The DAP configuration from user's `dap.lua`
- claudecode.lua, opencode.lua, lazygit.lua plugins
