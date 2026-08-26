{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.tmux-navigator = {
      enable = true;
      # Our own <C-hjkl> maps below cover tmux too, via TmuxNavigate*.
      settings.no_mappings = 1;
    };

    extraPlugins = with pkgs.vimPlugins; [
      render-markdown-nvim
      persistence-nvim
      plenary-nvim
    ];

    extraConfigLua = ''
      -- Seamless <C-hjkl> across nvim splits and herdr panes (or tmux panes when
      -- not in herdr). Herdr half: modules/llm-agents/herdr-nav.sh.
      -- From paulbkim-dev/vim-herdr-navigation's editor/nvim.lua.
      local function nav(wincmd, dir)
        local prev = vim.api.nvim_get_current_win()
        vim.cmd("wincmd " .. wincmd)
        if vim.api.nvim_get_current_win() ~= prev then
          return -- moved within neovim
        end
        -- At a split edge: cross into the surrounding multiplexer.
        if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
          -- Target this pane explicitly: --current is the server's globally
          -- focused pane, which is not necessarily the one we are in.
          local herdr = vim.env.HERDR_BIN_PATH
          if herdr == nil or herdr == "" then
            herdr = "herdr"
          end
          vim.fn.system({
            herdr, "pane", "focus", "--direction", dir, "--pane", vim.env.HERDR_PANE_ID,
          })
        elseif vim.env.TMUX and vim.env.TMUX ~= "" then
          local tmux = { left = "Left", down = "Down", up = "Up", right = "Right" }
          pcall(vim.cmd, "TmuxNavigate" .. tmux[dir])
        end
      end

      for _, m in ipairs({
        { "<C-h>", "h", "left" },
        { "<C-j>", "j", "down" },
        { "<C-k>", "k", "up" },
        { "<C-l>", "l", "right" },
      }) do
        vim.keymap.set("n", m[1], function() nav(m[2], m[3]) end,
          { silent = true, desc = "Navigate " .. m[3] .. " (vim/herdr)" })
      end

      -- render-markdown setup
      require("render-markdown").setup({
        code = {
          sign = false,
          width = "block",
          right_pad = 1,
        },
        heading = {
          sign = false,
          icons = {},
        },
      })
      Snacks.toggle({
        name = "Render Markdown",
        get = require("render-markdown").get,
        set = require("render-markdown").set,
      }):map("<leader>um")

      -- persistence.nvim setup
      require("persistence").setup({})
      vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore Session" })
      vim.keymap.set("n", "<leader>qS", function() require("persistence").select() end, { desc = "Select Session" })
      vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore Last Session" })
      vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't Save Current Session" })
    '';
  };
}
