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
      lazyLoad.settings = {
        cmd = [
          "DiffviewOpen"
          "DiffviewClose"
          "DiffviewFileHistory"
          "DiffviewToggleFiles"
          "DiffviewFocusFiles"
        ];
        keys = [
          {
            __unkeyed-1 = "<leader>gd";
            __unkeyed-2.__raw = ''
              function()
                local lib = require("diffview.lib")
                if lib.get_current_view() then
                  vim.cmd("DiffviewClose")
                else
                  vim.cmd("DiffviewOpen")
                end
              end
            '';
            desc = "Toggle Diffview";
          }
          {
            __unkeyed-1 = "<leader>gH";
            __unkeyed-2 = "<cmd>DiffviewFileHistory %<cr>";
            desc = "File History";
          }
        ];
      };
    };
  };
}
