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
        diagnostics_indicator.__raw = ''
          function(_, _, diag)
            local icons = { Error = " ", Warn = " ", Info = " ", Hint = " " }
            local ret = (diag.error and icons.Error .. diag.error .. " " or "")
              .. (diag.warning and icons.Warn .. diag.warning or "")
            return vim.trim(ret)
          end
        '';
        offsets = [
          {
            filetype = "neo-tree";
            text = "Neo-tree";
            highlight = "Directory";
            text_align = "left";
          }
          {
            filetype = "snacks_layout_box";
          }
        ];
        get_element_icon.__raw = ''
          function(opts)
            local ft_icons = {
              octo = " ",
              gh = " ",
              ["markdown.gh"] = " ",
            }
            return ft_icons[opts.filetype]
          end
        '';
        style_preset.__raw = "require('bufferline').style_preset.default";
        themable = true;
        show_buffer_close_icons = true;
        show_close_icon = false;
        separator_style = "thin";
        indicator = {
          style = "icon";
          icon = "▎";
        };
        modified_icon = "● ";
        left_trunc_marker = "";
        right_trunc_marker = "";
      };
      settings.highlights.__raw = ''require("catppuccin.special.bufferline").get_theme()'';
    };

    keymaps = [
      { mode = "n"; key = "<leader>bp"; action = "<Cmd>BufferLineTogglePin<CR>"; options.desc = "Toggle Pin"; }
      { mode = "n"; key = "<leader>bP"; action = "<Cmd>BufferLineGroupClose ungrouped<CR>"; options.desc = "Delete Non-Pinned Buffers"; }
      { mode = "n"; key = "<leader>br"; action = "<Cmd>BufferLineCloseRight<CR>"; options.desc = "Delete Buffers to the Right"; }
      { mode = "n"; key = "<leader>bl"; action = "<Cmd>BufferLineCloseLeft<CR>"; options.desc = "Delete Buffers to the Left"; }
      { mode = "n"; key = "<leader>bj"; action = "<Cmd>BufferLinePick<CR>"; options.desc = "Pick Buffer"; }
      { mode = "n"; key = "<S-h>"; action = "<cmd>BufferLineCyclePrev<cr>"; options.desc = "Prev Buffer"; }
      { mode = "n"; key = "<S-l>"; action = "<cmd>BufferLineCycleNext<cr>"; options.desc = "Next Buffer"; }
      { mode = "n"; key = "[b"; action = "<cmd>BufferLineCyclePrev<cr>"; options.desc = "Prev Buffer"; }
      { mode = "n"; key = "]b"; action = "<cmd>BufferLineCycleNext<cr>"; options.desc = "Next Buffer"; }
      { mode = "n"; key = "[B"; action = "<cmd>BufferLineMovePrev<cr>"; options.desc = "Move buffer prev"; }
      { mode = "n"; key = "]B"; action = "<cmd>BufferLineMoveNext<cr>"; options.desc = "Move buffer next"; }
      # snacks notification keymaps
      { mode = "n"; key = "<leader>n"; action.__raw = ''
          function()
            if Snacks.config.picker and Snacks.config.picker.enabled then
              Snacks.picker.notifications()
            else
              Snacks.notifier.show_history()
            end
          end
        ''; options.desc = "Notification History"; }
      { mode = "n"; key = "<leader>un"; action.__raw = "function() Snacks.notifier.hide() end"; options.desc = "Dismiss All Notifications"; }
    ];

    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          theme = "auto";
          globalstatus = true;
          section_separators = { left = ""; right = ""; };
          disabled_filetypes.statusline = [ "dashboard" "alpha" "ministarter" "snacks_dashboard" ];
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "branch" ];
          lualine_c = [
            {
              __unkeyed-1 = "diagnostics";
              symbols = {
                error = " ";
                warn = " ";
                info = " ";
                hint = " ";
              };
            }
            { __unkeyed-1 = "filetype"; icon_only = true; separator = ""; padding = { left = 1; right = 0; }; }
            { __unkeyed-1 = "filename"; path = 1; }
          ];
          lualine_x = [
            {
              __unkeyed-1.__raw = ''function() return require("noice").api.status.command.get() end'';
              cond.__raw = ''function() return package.loaded["noice"] and require("noice").api.status.command.has() end'';
              color.__raw = ''function() return { fg = Snacks.util.color("Statement") } end'';
            }
            {
              __unkeyed-1.__raw = ''function() return require("noice").api.status.mode.get() end'';
              cond.__raw = ''function() return package.loaded["noice"] and require("noice").api.status.mode.has() end'';
              color.__raw = ''function() return { fg = Snacks.util.color("Constant") } end'';
            }
            {
              __unkeyed-1.__raw = ''function() return "  " .. require("dap").status() end'';
              cond.__raw = ''function() return package.loaded["dap"] and require("dap").status() ~= "" end'';
              color.__raw = ''function() return { fg = Snacks.util.color("Debug") } end'';
            }
            {
              __unkeyed-1 = "diff";
              symbols = {
                added = " ";
                modified = " ";
                removed = " ";
              };
              source.__raw = ''
                function()
                  local gitsigns = vim.b.gitsigns_status_dict
                  if gitsigns then
                    return {
                      added = gitsigns.added,
                      modified = gitsigns.changed,
                      removed = gitsigns.removed,
                    }
                  end
                end
              '';
            }
          ];
          lualine_y = [
            { __unkeyed-1 = "progress"; separator = " "; padding = { left = 1; right = 0; }; }
            { __unkeyed-1 = "location"; padding = { left = 0; right = 1; }; }
          ];
          lualine_z = [
            { __unkeyed-1.__raw = ''function() return " " .. os.date("%R") end''; }
          ];
        };
        extensions = [ "neo-tree" "lazy" "fzf" ];
      };
    };

    plugins.noice = {
      enable = true;
      luaConfig.pre = ''
        -- HACK: noice shows messages from before it was enabled,
        -- but this is not ideal when Lazy is installing plugins,
        -- so clear the messages in this case.
        if vim.o.filetype == "lazy" then
          vim.cmd([[messages clear]])
        end
      '';
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
                { find = "%d+ lines, %d+ bytes"; }
                { find = "; after #%d+"; }
                { find = "; before #%d+"; }
              ];
            };
            view = "mini";
          }
          {
            filter = {
              event = "msg_show";
              find = "line %d+ of %d+";
            };
            opts = { skip = true; };
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
          { __unkeyed-1 = "<leader>a"; group = "ai"; mode = [ "n" "v" ]; }
          { __unkeyed-1 = "<leader>ao"; group = "opencode"; mode = [ "n" "x" ]; }
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
      -- bufferline: fix when restoring a session
      vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })

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
        icons = {
          file = {
            ".keep" = { glyph = "󰊢"; hl = "MiniIconsGrey"; };
            "devcontainer.json" = { glyph = ""; hl = "MiniIconsAzure"; };
          };
          filetype = {
            dotenv = { glyph = ""; hl = "MiniIconsYellow"; };
          };
        };
      };
    };

    extraConfigLuaPre = ''
      -- mini.icons: mock nvim-web-devicons so plugins that depend on it still work
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    '';
  };
}
