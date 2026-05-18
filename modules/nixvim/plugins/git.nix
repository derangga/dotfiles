{ ... }:

{
  programs.nixvim = {
    plugins.diffview = {
      enable = true;
      settings = {
        view = {
          merge_tool = {
            layout = "diff3_mixed";
          };
        };
      };
    };

    extraConfigLua = ''
      vim.keymap.set("n", "<leader>gd", function()
        local lib = require("diffview.lib")
        if lib.get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end, { desc = "Toggle Diffview" })

      vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History" })
    '';
  };
}
