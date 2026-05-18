{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.flash = {
      enable = true;
      settings = { };
    };

    keymaps = [
      { mode = [ "n" "x" "o" ]; key = "s"; action.__raw = "function() require('flash').jump() end"; options.desc = "Flash"; }
      { mode = [ "n" "o" "x" ]; key = "S"; action.__raw = "function() require('flash').treesitter() end"; options.desc = "Flash Treesitter"; }
      { mode = "o"; key = "r"; action.__raw = "function() require('flash').remote() end"; options.desc = "Remote Flash"; }
      { mode = [ "o" "x" ]; key = "R"; action.__raw = "function() require('flash').treesitter_search() end"; options.desc = "Treesitter Search"; }
      { mode = "c"; key = "<c-s>"; action.__raw = "function() require('flash').toggle() end"; options.desc = "Toggle Flash Search"; }
      {
        mode = [ "n" "o" "x" ];
        key = "<c-space>";
        action.__raw = ''
          function()
            require("flash").treesitter({
              actions = {
                ["<c-space>"] = "next",
                ["<BS>"] = "prev",
              },
            })
          end
        '';
        options.desc = "Treesitter Incremental Selection";
      }
    ];

    plugins.gitsigns = {
      enable = true;
      settings = {
        signs = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
          untracked.text = "▎";
        };
        signs_staged = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
        };
        on_attach = {
          __raw = ''
            function(buffer)
              local gs = package.loaded.gitsigns

              local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
              end

              map("n", "]h", function()
                if vim.wo.diff then
                  vim.cmd.normal({ "]c", bang = true })
                else
                  gs.nav_hunk("next")
                end
              end, "Next Hunk")
              map("n", "[h", function()
                if vim.wo.diff then
                  vim.cmd.normal({ "[c", bang = true })
                else
                  gs.nav_hunk("prev")
                end
              end, "Prev Hunk")
              map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
              map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
              map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
              map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
              map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
              map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
              map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
              map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
              map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
              map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
              map("n", "<leader>ghd", gs.diffthis, "Diff This")
              map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
              map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
            end
          '';
        };
      };
    };

    plugins.trouble = {
      enable = true;
      settings = {
        modes = {
          lsp = {
            win = { position = "right"; };
          };
        };
      };
    };

    plugins.todo-comments = {
      enable = true;
      settings = { };
    };

    extraPlugins = [ pkgs.vimPlugins.grug-far-nvim ];

    extraConfigLua = ''
      -- grug-far setup
      require("grug-far").setup({ headerMaxWidth = 80 })

      -- grug-far keymap
      vim.keymap.set({ "n", "x" }, "<leader>sr", function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end, { desc = "Search and Replace" })

      -- trouble keymaps
      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
      vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
      vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols (Trouble)" })
      vim.keymap.set("n", "<leader>cS", "<cmd>Trouble lsp toggle<cr>", { desc = "LSP references/definitions/... (Trouble)" })
      vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
      vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
      vim.keymap.set("n", "[q", function()
        if require("trouble").is_open() then
          require("trouble").prev({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then vim.notify(err, vim.log.levels.ERROR) end
        end
      end, { desc = "Previous Trouble/Quickfix Item" })
      vim.keymap.set("n", "]q", function()
        if require("trouble").is_open() then
          require("trouble").next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then vim.notify(err, vim.log.levels.ERROR) end
        end
      end, { desc = "Next Trouble/Quickfix Item" })

      -- todo-comments keymaps
      vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo Comment" })
      vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous Todo Comment" })
      vim.keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo (Trouble)" })
      vim.keymap.set("n", "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", { desc = "Todo/Fix/Fixme (Trouble)" })
      vim.keymap.set("n", "<leader>st", function() Snacks.picker.todo_comments() end, { desc = "Todo" })
      vim.keymap.set("n", "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, { desc = "Todo/Fix/Fixme" })

      -- gitsigns toggle
      Snacks.toggle({
        name = "Git Signs",
        get = function()
          return require("gitsigns.config").config.signcolumn
        end,
        set = function(state)
          require("gitsigns").toggle_signs(state)
        end,
      }):map("<leader>uG")

      -- User custom: toggle git blame
      vim.keymap.set("n", "<leader>tb", function()
        require("gitsigns").toggle_current_line_blame()
      end, { desc = "Toggle git line blame" })
    '';
  };
}
