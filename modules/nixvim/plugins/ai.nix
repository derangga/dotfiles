{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      claudecode-nvim
      opencode-nvim
    ];

    extraConfigLua = ''
      -- claudecode.nvim
      require("claudecode").setup({
        terminal_cmd = "claude --dangerously-skip-permissions",
        terminal = {
          split_width_percentage = 0.40,
          provider = "native",
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
      vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
      vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
      vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
      vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
      vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "NvimTree", "neo-tree", "oil" },
        callback = function(ev)
          vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = ev.buf, desc = "Add file" })
        end,
      })
      vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
      vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

      -- opencode.nvim
      vim.o.autoread = true

      vim.keymap.set({ "n", "x" }, "<leader>aoa", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode…" })
      vim.keymap.set({ "n", "x" }, "<leader>aox", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<leader>aot", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })
    '';
  };
}
