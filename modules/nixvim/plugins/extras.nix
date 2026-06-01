{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.tmux-navigator.enable = true;

    extraPlugins = with pkgs.vimPlugins; [
      render-markdown-nvim
      persistence-nvim
      plenary-nvim
    ];

    extraConfigLua = ''
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
