{ ... }:

{
  programs.nixvim = {
    keymaps = [
      # better up/down
      { mode = [ "n" "x" ]; key = "j"; action = "v:count == 0 ? 'gj' : 'j'"; options = { desc = "Down"; expr = true; silent = true; }; }
      { mode = [ "n" "x" ]; key = "<Down>"; action = "v:count == 0 ? 'gj' : 'j'"; options = { desc = "Down"; expr = true; silent = true; }; }
      { mode = [ "n" "x" ]; key = "k"; action = "v:count == 0 ? 'gk' : 'k'"; options = { desc = "Up"; expr = true; silent = true; }; }
      { mode = [ "n" "x" ]; key = "<Up>"; action = "v:count == 0 ? 'gk' : 'k'"; options = { desc = "Up"; expr = true; silent = true; }; }

      # Move Lines
      { mode = "n"; key = "<A-j>"; action = "<cmd>execute 'move .+' . v:count1<cr>=="; options.desc = "Move Down"; }
      { mode = "n"; key = "<A-k>"; action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>=="; options.desc = "Move Up"; }
      { mode = "i"; key = "<A-j>"; action = "<esc><cmd>m .+1<cr>==gi"; options.desc = "Move Down"; }
      { mode = "i"; key = "<A-k>"; action = "<esc><cmd>m .-2<cr>==gi"; options.desc = "Move Up"; }
      { mode = "v"; key = "<A-j>"; action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv"; options.desc = "Move Down"; }
      { mode = "v"; key = "<A-k>"; action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv"; options.desc = "Move Up"; }

      # buffers
      { mode = "n"; key = "<S-h>"; action = "<cmd>bprevious<cr>"; options.desc = "Prev Buffer"; }
      { mode = "n"; key = "<S-l>"; action = "<cmd>bnext<cr>"; options.desc = "Next Buffer"; }
      { mode = "n"; key = "[b"; action = "<cmd>bprevious<cr>"; options.desc = "Prev Buffer"; }
      { mode = "n"; key = "]b"; action = "<cmd>bnext<cr>"; options.desc = "Next Buffer"; }
      { mode = "n"; key = "<leader>bb"; action = "<cmd>e #<cr>"; options.desc = "Switch to Other Buffer"; }
      { mode = "n"; key = "<leader>`"; action = "<cmd>e #<cr>"; options.desc = "Switch to Other Buffer"; }
      { mode = "n"; key = "<leader>bD"; action = "<cmd>:bd<cr>"; options.desc = "Delete Buffer and Window"; }

      # Clear search and redraw
      { mode = "n"; key = "<leader>ur"; action = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>"; options.desc = "Redraw / Clear hlsearch / Diff Update"; }

      # saner n/N search direction
      { mode = "n"; key = "n"; action = "'Nn'[v:searchforward].'zv'"; options = { expr = true; desc = "Next Search Result"; }; }
      { mode = "x"; key = "n"; action = "'Nn'[v:searchforward]"; options = { expr = true; desc = "Next Search Result"; }; }
      { mode = "o"; key = "n"; action = "'Nn'[v:searchforward]"; options = { expr = true; desc = "Next Search Result"; }; }
      { mode = "n"; key = "N"; action = "'nN'[v:searchforward].'zv'"; options = { expr = true; desc = "Prev Search Result"; }; }
      { mode = "x"; key = "N"; action = "'nN'[v:searchforward]"; options = { expr = true; desc = "Prev Search Result"; }; }
      { mode = "o"; key = "N"; action = "'nN'[v:searchforward]"; options = { expr = true; desc = "Prev Search Result"; }; }

      # Add undo break-points
      { mode = "i"; key = ","; action = ",<c-g>u"; }
      { mode = "i"; key = "."; action = ".<c-g>u"; }
      { mode = "i"; key = ";"; action = ";<c-g>u"; }

      # save file
      { mode = [ "i" "x" "n" "s" ]; key = "<C-s>"; action = "<cmd>w<cr><esc>"; options.desc = "Save File"; }

      # keywordprg
      { mode = "n"; key = "<leader>K"; action = "<cmd>norm! K<cr>"; options.desc = "Keywordprg"; }

      # better indenting
      { mode = "x"; key = "<"; action = "<gv"; }
      { mode = "x"; key = ">"; action = ">gv"; }

      # commenting
      { mode = "n"; key = "gco"; action = "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>"; options.desc = "Add Comment Below"; }
      { mode = "n"; key = "gcO"; action = "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>"; options.desc = "Add Comment Above"; }

      # new file
      { mode = "n"; key = "<leader>fn"; action = "<cmd>enew<cr>"; options.desc = "New File"; }

      # quit
      { mode = "n"; key = "<leader>qq"; action = "<cmd>qa<cr>"; options.desc = "Quit All"; }

      # windows
      { mode = "n"; key = "<leader>-"; action = "<C-W>s"; options = { desc = "Split Window Below"; remap = true; }; }
      { mode = "n"; key = "<leader>|"; action = "<C-W>v"; options = { desc = "Split Window Right"; remap = true; }; }
      { mode = "n"; key = "<leader>wd"; action = "<C-W>c"; options = { desc = "Delete Window"; remap = true; }; }

      # tabs
      { mode = "n"; key = "<leader><tab>l"; action = "<cmd>tablast<cr>"; options.desc = "Last Tab"; }
      { mode = "n"; key = "<leader><tab>o"; action = "<cmd>tabonly<cr>"; options.desc = "Close Other Tabs"; }
      { mode = "n"; key = "<leader><tab>f"; action = "<cmd>tabfirst<cr>"; options.desc = "First Tab"; }
      { mode = "n"; key = "<leader><tab><tab>"; action = "<cmd>tabnew<cr>"; options.desc = "New Tab"; }
      { mode = "n"; key = "<leader><tab>]"; action = "<cmd>tabnext<cr>"; options.desc = "Next Tab"; }
      { mode = "n"; key = "<leader><tab>d"; action = "<cmd>tabclose<cr>"; options.desc = "Close Tab"; }
      { mode = "n"; key = "<leader><tab>["; action = "<cmd>tabprevious<cr>"; options.desc = "Previous Tab"; }

      # User custom: jk → ESC
      { mode = "i"; key = "jk"; action = "<ESC>"; }

      # User custom: comment toggle
      { mode = "n"; key = "<leader>/"; action = "gcc"; options = { desc = "toggle comment"; remap = true; }; }
      { mode = "v"; key = "<leader>/"; action = "gc"; options = { desc = "toggle comment"; remap = true; }; }

      # User custom: window resize
      { mode = "n"; key = "<Esc>b"; action = "<cmd>vertical resize -2<CR>"; options.desc = "Decrease window width"; }
      { mode = "n"; key = "<Esc>f"; action = "<cmd>vertical resize +2<CR>"; options.desc = "Increase window width"; }
      { mode = "n"; key = "<M-Up>"; action = "<cmd>resize +2<CR>"; options.desc = "Increase window height"; }
      { mode = "n"; key = "<M-Down>"; action = "<cmd>resize -2<CR>"; options.desc = "Decrease window height"; }
    ];

    extraConfigLua = ''
      local map = vim.keymap.set

      -- escape clears search highlight
      map({ "i", "n", "s" }, "<esc>", function()
        vim.cmd("noh")
        return "<esc>"
      end, { expr = true, desc = "Escape and Clear hlsearch" })

      -- buffer delete (Snacks)
      map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
      map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })

      -- terminal (Snacks)
      map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
      map("n", "<leader>ft", function() Snacks.terminal() end, { desc = "Terminal (Root Dir)" })
      map({ "n", "t" }, "<c-/>", function() Snacks.terminal.focus() end, { desc = "Terminal (Root Dir)" })
      map({ "n", "t" }, "<c-_>", function() Snacks.terminal.focus() end, { desc = "which_key_ignore" })

      -- lazygit (Snacks)
      map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit (Root Dir)" })
      map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
      map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })
      map("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
      map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
      map("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
      map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
      map({ "n", "x" }, "<leader>gY", function()
        Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
      end, { desc = "Git Browse (copy)" })

      -- git picker
      -- <leader>gd belongs to diffview toggle (git.nix, lz.n key trigger)
      map("n", "<leader>gD", function() Snacks.picker.git_diff() end, { desc = "Git Diff (hunks)" })
      map("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })

      -- scratch (Snacks)
      map("n", "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
      map("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })

      -- profiler scratch
      map("n", "<leader>dps", function() Snacks.profiler.scratch() end, { desc = "Profiler Scratch" })

      -- picker/search (Snacks)
      map("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers" })
      map("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "Command History" })
      map("n", "<leader><space>", function() Snacks.picker.files() end, { desc = "Find Files (Root Dir)" })
      map("n", "<leader>n", function() Snacks.picker.notifications() end, { desc = "Notification History" })
      -- find
      map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
      map("n", "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, { desc = "Buffers (all)" })
      map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files (Root Dir)" })
      map("n", "<leader>fF", function() Snacks.picker.files() end, { desc = "Find Files (cwd)" })
      map("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find Files (git-files)" })
      map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent" })
      map("n", "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true } }) end, { desc = "Recent (cwd)" })
      map("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })
      -- grep
      map("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
      map("n", "<leader>sB", function() Snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers" })
      map("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep (Root Dir)" })
      map("n", "<leader>sG", function() Snacks.picker.grep() end, { desc = "Grep (cwd)" })
      map({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "Visual selection or word (Root Dir)" })
      -- search
      map("n", '<leader>s"', function() Snacks.picker.registers() end, { desc = "Registers" })
      map("n", "<leader>s/", function() Snacks.picker.search_history() end, { desc = "Search History" })
      map("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "Autocmds" })
      map("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "Command History" })
      map("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands" })
      map("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
      map("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
      map("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages" })
      map("n", "<leader>sH", function() Snacks.picker.highlights() end, { desc = "Highlights" })
      map("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons" })
      map("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps" })
      map("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
      map("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location List" })
      map("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages" })
      map("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks" })
      map("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume" })
      map("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
      map("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "Undotree" })
      map("n", "<leader>uC", function() Snacks.picker.colorschemes() end, { desc = "Colorschemes" })

      -- autoformat toggles
      Snacks.toggle({
        name = "Auto Format (Global)",
        get = function() return vim.g.autoformat ~= false end,
        set = function(state) vim.g.autoformat = state end,
      }):map("<leader>uf")
      Snacks.toggle({
        name = "Auto Format (Buffer)",
        get = function() return vim.b.autoformat ~= false end,
        set = function(state) vim.b.autoformat = state end,
      }):map("<leader>uF")

      -- toggle options (Snacks)
      Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
      Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
      Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
      Snacks.toggle.diagnostics():map("<leader>ud")
      Snacks.toggle.line_number():map("<leader>ul")
      Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
      Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
      Snacks.toggle.treesitter():map("<leader>uT")
      Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
      Snacks.toggle.dim():map("<leader>uD")
      Snacks.toggle.animate():map("<leader>ua")
      Snacks.toggle.indent():map("<leader>ug")
      Snacks.toggle.scroll():map("<leader>uS")
      Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
      Snacks.toggle.zen():map("<leader>uz")
      if vim.lsp.inlay_hint then
        Snacks.toggle.inlay_hints():map("<leader>uh")
      end

      -- notifications
      map("n", "<leader>un", function() Snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })

      -- diagnostics
      local diagnostic_goto = function(next, severity)
        return function()
          vim.diagnostic.jump({
            count = (next and 1 or -1) * vim.v.count1,
            severity = severity and vim.diagnostic.severity[severity] or nil,
            float = true,
          })
        end
      end
      map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
      map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
      map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
      map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
      map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
      map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
      map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

      -- format
      map({ "n", "x" }, "<leader>cf", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format" })

      -- word nav (Snacks)
      map("n", "]]", function() Snacks.words.jump(vim.v.count1) end, { desc = "Next Reference" })
      map("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })
      map("n", "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, { desc = "Next Reference (wrap)" })
      map("n", "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, { desc = "Prev Reference (wrap)" })

      -- location list / quickfix list
      map("n", "<leader>xl", function()
        local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
        if not success and err then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end, { desc = "Location List" })
      map("n", "<leader>xq", function()
        local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
        if not success and err then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end, { desc = "Quickfix List" })

      -- inspect
      map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
      map("n", "<leader>uI", function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "Inspect Tree" })
    '';
  };
}
