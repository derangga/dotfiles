{ pkgs, fff-nvim, ... }:

{
  programs.nixvim = {
    extraPlugins = [ fff-nvim.packages.${pkgs.stdenv.hostPlatform.system}.fff-nvim ];

    extraConfigLua = ''
      require("fff").setup({
        prompt = "🦉 ",
        layout = {
          prompt_position = "top",
        },
      })

      vim.keymap.set("n", "<leader>ff", function() require("fff").find_files() end, { desc = "Find Files" })
      vim.keymap.set("n", "<leader><space>", function() require("fff").find_files() end, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fz", function()
        require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
      end, { desc = "Live Fuzzy Grep" })
      vim.keymap.set("n", "<leader>sg", function() require("fff").live_grep() end, { desc = "Live Grep" })
    '';
  };
}
