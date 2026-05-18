{ ... }:

{
  programs.nixvim = {
    plugins.lint = {
      enable = true;
      lintersByFt = {
        fish = [ "fish" ];
        # "*" runs on all filetypes
        # "_" runs as a fallback when no other linter matches
      };
    };

    extraConfigLua = ''
      -- LazyVim-style lint runner: debounced, supports fallback "_"/global "*"
      -- linters, per-linter `condition` functions, and composite filetypes.
      do
        local lint = require("lint")
        local events = { "BufWritePost", "BufReadPost", "InsertLeave" }

        local function debounce(ms, fn)
          local timer = vim.uv.new_timer()
          return function(...)
            local argv = { ... }
            timer:start(ms, 0, function()
              timer:stop()
              vim.schedule_wrap(fn)(unpack(argv))
            end)
          end
        end

        local function run_lint()
          local names = lint._resolve_linter_by_ft(vim.bo.filetype)
          names = vim.list_extend({}, names)

          if #names == 0 then
            vim.list_extend(names, lint.linters_by_ft["_"] or {})
          end
          vim.list_extend(names, lint.linters_by_ft["*"] or {})

          local ctx = { filename = vim.api.nvim_buf_get_name(0) }
          ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")

          names = vim.tbl_filter(function(name)
            local linter = lint.linters[name]
            if not linter then
              vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
              return false
            end
            if type(linter) == "table" and linter.condition and not linter.condition(ctx) then
              return false
            end
            return true
          end, names)

          if #names > 0 then
            lint.try_lint(names)
          end
        end

        vim.api.nvim_create_autocmd(events, {
          group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
          callback = debounce(100, run_lint),
        })
      end
    '';
  };
}
