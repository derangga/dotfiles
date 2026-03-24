{ ... }:

{
  programs.nixvim = {
    plugins.web-devicons.enable = false;

    plugins.bufferline = {
      enable = true;
      settings.options = {
        close_command.__raw = "function(n) Snacks.bufdelete(n) end";
        right_mouse_command.__raw = "function(n) Snacks.bufdelete(n) end";
        diagnostics = "nvim_lsp";
        always_show_bufferline = false;
      };
    };

    keymaps = [
      { mode = "n"; key = "<leader>bp"; action = "<Cmd>BufferLineTogglePin<CR>"; options.desc = "Toggle Pin"; }
      { mode = "n"; key = "<leader>bP"; action = "<Cmd>BufferLineGroupClose ungrouped<CR>"; options.desc = "Delete Non-Pinned Buffers"; }
      { mode = "n"; key = "<leader>br"; action = "<Cmd>BufferLineCloseRight<CR>"; options.desc = "Delete Buffers to the Right"; }
      { mode = "n"; key = "<leader>bl"; action = "<Cmd>BufferLineCloseLeft<CR>"; options.desc = "Delete Buffers to the Left"; }
      { mode = "n"; key = "<leader>bj"; action = "<Cmd>BufferLinePick<CR>"; options.desc = "Pick Buffer"; }
      { mode = "n"; key = "[B"; action = "<cmd>BufferLineMovePrev<cr>"; options.desc = "Move buffer prev"; }
      { mode = "n"; key = "]B"; action = "<cmd>BufferLineMoveNext<cr>"; options.desc = "Move buffer next"; }
    ];

    plugins.lualine = {
      enable = true;
      settings.options = {
        section_separators = {
          left = "";
          right = "";
        };
      };
    };

    plugins.noice = {
      enable = true;
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        routes = [
          {
            filter = {
              event = "msg_show";
              any = [
                { find = "%d+L, %d+B"; }
                { find = "; after #%d+"; }
                { find = "; before #%d+"; }
              ];
            };
            view = "mini";
          }
        ];
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
        };
      };
    };

    plugins.which-key = {
      enable = true;
      settings = {
        preset = "helix";
        spec = [
          { __unkeyed-1 = "<leader><tab>"; group = "tabs"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>b"; group = "buffer"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>c"; group = "code"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>d"; group = "debug"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>dp"; group = "profiler"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>f"; group = "file/find"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>g"; group = "git"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>gh"; group = "hunks"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>q"; group = "quit/session"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>s"; group = "search"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>t"; group = "toggle"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>u"; group = "ui"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>w"; group = "windows"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>x"; group = "diagnostics/quickfix"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "["; group = "prev"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "]"; group = "next"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "g"; group = "goto"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "gs"; group = "surround"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "<leader>sn"; group = "+noice"; mode = [ "n" "x" ]; }
          { __unkeyed-1 = "z"; group = "fold"; mode = [ "n" "x" ]; }
        ];
      };
    };

    extraConfigLua = ''
      -- which-key keymaps
      vim.keymap.set("n", "<leader>?", function()
        require("which-key").show({ global = false })
      end, { desc = "Buffer Keymaps (which-key)" })
      vim.keymap.set("n", "<c-w><space>", function()
        require("which-key").show({ keys = "<c-w>", loop = true })
      end, { desc = "Window Hydra Mode (which-key)" })

      -- noice keymaps
      vim.keymap.set("c", "<S-Enter>", function()
        require("noice").redirect(vim.fn.getcmdline())
      end, { desc = "Redirect Cmdline" })
      vim.keymap.set("n", "<leader>snl", function()
        require("noice").cmd("last")
      end, { desc = "Noice Last Message" })
      vim.keymap.set("n", "<leader>snh", function()
        require("noice").cmd("history")
      end, { desc = "Noice History" })
      vim.keymap.set("n", "<leader>sna", function()
        require("noice").cmd("all")
      end, { desc = "Noice All" })
      vim.keymap.set("n", "<leader>snd", function()
        require("noice").cmd("dismiss")
      end, { desc = "Dismiss All" })
      vim.keymap.set("n", "<leader>snt", function()
        require("noice").cmd("pick")
      end, { desc = "Noice Picker" })
      vim.keymap.set({ "i", "n", "s" }, "<c-f>", function()
        if not require("noice.lsp").scroll(4) then
          return "<c-f>"
        end
      end, { silent = true, expr = true, desc = "Scroll Forward" })
      vim.keymap.set({ "i", "n", "s" }, "<c-b>", function()
        if not require("noice.lsp").scroll(-4) then
          return "<c-b>"
        end
      end, { silent = true, expr = true, desc = "Scroll Backward" })
    '';

    plugins.mini = {
      enable = true;
      modules = {
        icons = { };
      };
    };
  };
}
