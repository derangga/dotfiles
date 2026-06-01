{ ... }:

{
  programs.nixvim = {
    extraConfigLua = ''
      -- Explorer keymaps (Snacks explorer)
      vim.keymap.set("n", "<leader>fe", function() Snacks.explorer() end, { desc = "Explorer Snacks (root dir)" })
      vim.keymap.set("n", "<leader>fE", function() Snacks.explorer() end, { desc = "Explorer Snacks (cwd)" })
      vim.keymap.set("n", "<leader>e", "<leader>fe", { desc = "Explorer Snacks (root dir)", remap = true })
      vim.keymap.set("n", "<leader>E", "<leader>fE", { desc = "Explorer Snacks (cwd)", remap = true })

      -- Git / buffer explorers (Snacks pickers)
      vim.keymap.set("n", "<leader>ge", function() Snacks.picker.git_status() end, { desc = "Git Explorer" })
      vim.keymap.set("n", "<leader>be", function() Snacks.picker.buffers() end, { desc = "Buffer Explorer" })
    '';
  };
}
