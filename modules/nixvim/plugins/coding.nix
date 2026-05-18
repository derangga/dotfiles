{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.mini = {
      enable = true;
      modules = {
        hipatterns = {
          highlighters = {
            hex_color.__raw = ''require("mini.hipatterns").gen_highlighter.hex_color()'';
          };
        };
        pairs = {
          modes = {
            insert = true;
            command = true;
            terminal = false;
          };
        };
        ai = {
          n_lines = 500;
          custom_textobjects = {
            o.__raw = ''
              require("mini.ai").gen_spec.treesitter({
                a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                i = { "@block.inner", "@conditional.inner", "@loop.inner" },
              })
            '';
            f.__raw = ''require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" })'';
            c.__raw = ''require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" })'';
            t = {
              __unkeyed-1 = "<([%p%w]-)%f[^<%w][^<>]->.-</%1>";
              __unkeyed-2 = "^<.->().*()</[^/]->$";
            };
            d = {
              __unkeyed-1 = "%f[%d]%d+";
            };
            e = {
              __unkeyed-1 = {
                __unkeyed-1 = "%u[%l%d]+%f[^%l%d]";
                __unkeyed-2 = "%f[%S][%l%d]+%f[^%l%d]";
                __unkeyed-3 = "%f[%P][%l%d]+%f[^%l%d]";
                __unkeyed-4 = "^[%l%d]+%f[^%l%d]";
              };
              __unkeyed-2 = "^().*()$";
            };
            g.__raw = ''
              function(ai_type)
                local start_line, end_line = 1, vim.fn.line("$")
                if ai_type == "i" then
                  local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
                  if first_nonblank == 0 or last_nonblank == 0 then
                    return { from = { line = start_line, col = 1 } }
                  end
                  start_line, end_line = first_nonblank, last_nonblank
                end
                local to_col = math.max(vim.fn.getline(end_line):len(), 1)
                return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
              end
            '';
            u.__raw = ''require("mini.ai").gen_spec.function_call()'';
            U.__raw = ''require("mini.ai").gen_spec.function_call({ name_pattern = "[%w_]" })'';
          };
        };
      };
    };

    extraPlugins = [
      pkgs.vimPlugins.ts-comments-nvim
      pkgs.vimPlugins.lazydev-nvim
    ];

    extraConfigLua = ''
      -- ts-comments setup
      require("ts-comments").setup({})

      -- lazydev setup
      require("lazydev").setup({
        library = {
          { path = "''${3rd}/luv/library", words = { "vim%.uv" } },
          { path = "snacks.nvim", words = { "Snacks" } },
        },
      })

      -- mini.pairs: smart pairing logic (ported from LazyVim)
      do
        Snacks.toggle({
          name = "Mini Pairs",
          get = function()
            return not vim.g.minipairs_disable
          end,
          set = function(state)
            vim.g.minipairs_disable = not state
          end,
        }):map("<leader>up")

        local pairs = require("mini.pairs")
        local open = pairs.open
        pairs.open = function(pair, neigh_pattern)
          if vim.fn.getcmdline() ~= "" then
            return open(pair, neigh_pattern)
          end
          local o, c = pair:sub(1, 1), pair:sub(2, 2)
          local line = vim.api.nvim_get_current_line()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local next = line:sub(cursor[2] + 1, cursor[2] + 1)
          local before = line:sub(1, cursor[2])
          -- markdown triple backtick completion
          if o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
            return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
          end
          -- skip autopair when next character matches pattern
          if next ~= "" and next:match([=[[%w%%%'%[%"%.%`%$]]=]) then
            return o
          end
          -- skip autopair when inside treesitter string nodes
          local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
          for _, capture in ipairs(ok and captures or {}) do
            if capture.capture == "string" then
              return o
            end
          end
          -- skip autopair when closing pairs outnumber opening pairs
          if next == c and c ~= o then
            local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
            local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
            if count_close > count_open then
              return o
            end
          end
          return open(pair, neigh_pattern)
        end
      end

      -- mini.ai: register text object descriptions with which-key
      do
        local objects = {
          { " ", desc = "whitespace" },
          { '"', desc = '" string' },
          { "'", desc = "' string" },
          { "(", desc = "() block" },
          { ")", desc = "() block with ws" },
          { "<", desc = "<> block" },
          { ">", desc = "<> block with ws" },
          { "?", desc = "user prompt" },
          { "U", desc = "use/call without dot" },
          { "[", desc = "[] block" },
          { "]", desc = "[] block with ws" },
          { "_", desc = "underscore" },
          { "`", desc = "` string" },
          { "a", desc = "argument" },
          { "b", desc = ")]} block" },
          { "c", desc = "class" },
          { "d", desc = "digit(s)" },
          { "e", desc = "CamelCase / snake_case" },
          { "f", desc = "function" },
          { "g", desc = "entire file" },
          { "i", desc = "indent" },
          { "o", desc = "block, conditional, loop" },
          { "q", desc = "quote `\"'" },
          { "t", desc = "tag" },
          { "u", desc = "use/call" },
          { "{", desc = "{} block" },
          { "}", desc = "{} with ws" },
        }

        local ret = { mode = { "o", "x" } }
        local mappings = vim.tbl_extend("force", {}, {
          around = "a",
          inside = "i",
          around_next = "an",
          inside_next = "in",
          around_last = "al",
          inside_last = "il",
        })
        mappings.goto_left = nil
        mappings.goto_right = nil

        for name, prefix in pairs(mappings) do
          name = name:gsub("^around_", ""):gsub("^inside_", "")
          ret[#ret + 1] = { prefix, group = name }
          for _, obj in ipairs(objects) do
            local desc = obj.desc
            if prefix:sub(1, 1) == "i" then
              desc = desc:gsub(" with ws", "")
            end
            ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
          end
        end
        require("which-key").add(ret, { notify = false })
      end
    '';
  };
}
