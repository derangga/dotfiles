{ ... }:

{
  programs.nixvim = {
    plugins.neo-tree = {
      enable = true;
      sources = [
        "filesystem"
        "buffers"
        "git_status"
      ];
      filesystem = {
        bindToCwd = false;
        followCurrentFile.enabled = true;
        useLibuvFileWatcher = true;
      };
      window.mappings = {
        l = "open";
        h = "close_node";
        "<space>" = "none";
        P = {
          command = "toggle_preview";
          config.use_float = false;
        };
        Y = {
          __raw = ''
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end
          '';
        };
      };
      defaultComponentConfigs = {
        indent = {
          withExpanders = true;
          expanderCollapsed = "";
          expanderExpanded = "";
        };
        gitStatus.symbols = {
          unstaged = "󰄱";
          staged = "󰱒";
        };
      };
    };

    extraConfigLua = ''
      -- Explorer keymaps (Snacks explorer)
      vim.keymap.set("n", "<leader>fe", function() Snacks.explorer() end, { desc = "Explorer Snacks (root dir)" })
      vim.keymap.set("n", "<leader>fE", function() Snacks.explorer() end, { desc = "Explorer Snacks (cwd)" })
      vim.keymap.set("n", "<leader>e", "<leader>fe", { desc = "Explorer Snacks (root dir)", remap = true })
      vim.keymap.set("n", "<leader>E", "<leader>fE", { desc = "Explorer Snacks (cwd)", remap = true })

      -- Neo-tree keymaps
      vim.keymap.set("n", "<leader>ge", function()
        require("neo-tree.command").execute({ source = "git_status", toggle = true })
      end, { desc = "Git Explorer" })
      vim.keymap.set("n", "<leader>be", function()
        require("neo-tree.command").execute({ source = "buffers", toggle = true })
      end, { desc = "Buffer Explorer" })
    '';
  };
}
