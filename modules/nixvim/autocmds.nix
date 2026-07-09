{ ... }:

{
  programs.nixvim = {
    autoGroups = {
      nixvim_checktime = {
        clear = true;
      };
      nixvim_highlight_yank = {
        clear = true;
      };
      nixvim_resize_splits = {
        clear = true;
      };
      nixvim_last_loc = {
        clear = true;
      };
      nixvim_close_with_q = {
        clear = true;
      };
      nixvim_man_unlisted = {
        clear = true;
      };
      nixvim_wrap_spell = {
        clear = true;
      };
      nixvim_json_conceal = {
        clear = true;
      };
      nixvim_auto_create_dir = {
        clear = true;
      };
    };

    autoCmd = [
      # Check if we need to reload the file when it changed
      {
        event = [
          "FocusGained"
          "TermClose"
          "TermLeave"
        ];
        group = "nixvim_checktime";
        callback.__raw = ''
          function()
            if vim.o.buftype ~= "nofile" then
              vim.cmd("checktime")
            end
          end
        '';
      }

      # Highlight on yank
      {
        event = "TextYankPost";
        group = "nixvim_highlight_yank";
        callback.__raw = ''
          function()
            (vim.hl or vim.highlight).on_yank()
          end
        '';
      }

      # Resize splits if window got resized
      {
        event = "VimResized";
        group = "nixvim_resize_splits";
        callback.__raw = ''
          function()
            local current_tab = vim.fn.tabpagenr()
            vim.cmd("tabdo wincmd =")
            vim.cmd("tabnext " .. current_tab)
          end
        '';
      }

      # Go to last loc when opening a buffer
      {
        event = "BufReadPost";
        group = "nixvim_last_loc";
        callback.__raw = ''
          function(event)
            local exclude = { "gitcommit" }
            local buf = event.buf
            if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].nixvim_last_loc then
              return
            end
            vim.b[buf].nixvim_last_loc = true
            local mark = vim.api.nvim_buf_get_mark(buf, '"')
            local lcount = vim.api.nvim_buf_line_count(buf)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end
        '';
      }

      # Close some filetypes with <q>
      {
        event = "FileType";
        group = "nixvim_close_with_q";
        pattern = [
          "PlenaryTestPopup"
          "checkhealth"
          "dap-float"
          "dbout"
          "gitsigns-blame"
          "grug-far"
          "help"
          "lspinfo"
          "neotest-output"
          "neotest-output-panel"
          "neotest-summary"
          "notify"
          "qf"
          "spectre_panel"
          "startuptime"
          "tsplayground"
        ];
        callback.__raw = ''
          function(event)
            vim.bo[event.buf].buflisted = false
            vim.schedule(function()
              vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
              end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
              })
            end)
          end
        '';
      }

      # Make it easier to close man-files when opened inline
      {
        event = "FileType";
        group = "nixvim_man_unlisted";
        pattern = [ "man" ];
        callback.__raw = ''
          function(event)
            vim.bo[event.buf].buflisted = false
          end
        '';
      }

      # Wrap and check for spell in text filetypes
      {
        event = "FileType";
        group = "nixvim_wrap_spell";
        pattern = [
          "text"
          "plaintex"
          "typst"
          "gitcommit"
          "markdown"
        ];
        callback.__raw = ''
          function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
          end
        '';
      }

      # Fix conceallevel for json files
      {
        event = "FileType";
        group = "nixvim_json_conceal";
        pattern = [
          "json"
          "jsonc"
          "json5"
        ];
        callback.__raw = ''
          function()
            vim.opt_local.conceallevel = 0
          end
        '';
      }

      # Auto create dir when saving a file
      {
        event = "BufWritePre";
        group = "nixvim_auto_create_dir";
        callback.__raw = ''
          function(event)
            if event.match:match("^%w%w+:[\\/][\\/]") then
              return
            end
            local file = vim.uv.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
          end
        '';
      }
    ];

    # User custom autocmds
    extraConfigLua = ''
      -- mdx filetype registration
      vim.filetype.add({
        extension = {
          mdx = "markdown.mdx",
        },
      })

      -- Show diagnostics float on cursor hold, but only on lines that have a
      -- diagnostic and only in normal mode (avoids opening on clean lines).
      local lspGroup = vim.api.nvim_create_augroup("Lsp", { clear = true })
      vim.api.nvim_create_autocmd("CursorHold", {
        group = lspGroup,
        callback = function()
          if vim.api.nvim_get_mode().mode ~= "n" then
            return
          end
          if #vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 }) == 0 then
            return
          end
          vim.diagnostic.open_float(nil, { focus = false, scope = "line" })
        end,
      })
    '';
  };
}
