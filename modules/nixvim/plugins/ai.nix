{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      claudecode-nvim
      opencode-nvim
    ];

    extraConfigLua = ''
      -- claudecode.nvim: defer setup() until first use. Its setup auto-starts a
      -- WebSocket server (auto_start = true), so running it lazily keeps startup clean.
      -- setup() also registers the :ClaudeCode* commands, hence load-before-command.
      local claudecode_ready = false
      local function ensure_claudecode()
        if not claudecode_ready then
          require("claudecode").setup({
            terminal_cmd = "claude --dangerously-skip-permissions",
            terminal = {
              split_width_percentage = 0.40,
              provider = "native",
            },
          })
          claudecode_ready = true
        end
      end
      local function claude_cmd(cmd)
        return function()
          ensure_claudecode()
          vim.cmd(cmd)
        end
      end
      -- :ClaudeCode* typed before any keymap fired -> setup defines the command,
      -- then vim retries it (see :h CmdUndefined)
      vim.api.nvim_create_autocmd("CmdUndefined", {
        pattern = "ClaudeCode*",
        callback = function() ensure_claudecode() end,
      })

      vim.keymap.set({ "n", "v" }, "<leader>ac", claude_cmd("ClaudeCode"), { desc = "Toggle Claude" })
      vim.keymap.set("n", "<leader>af", claude_cmd("ClaudeCodeFocus"), { desc = "Focus Claude" })
      vim.keymap.set("n", "<leader>ar", claude_cmd("ClaudeCode --resume"), { desc = "Resume Claude" })
      vim.keymap.set("n", "<leader>aC", claude_cmd("ClaudeCode --continue"), { desc = "Continue Claude" })
      vim.keymap.set("n", "<leader>ab", claude_cmd("ClaudeCodeAdd %"), { desc = "Add current buffer" })
      -- expr map so the native visual range still reaches ClaudeCodeSend (reads opts.range)
      vim.keymap.set("v", "<leader>as", function()
        ensure_claudecode()
        return "<cmd>ClaudeCodeSend<cr>"
      end, { desc = "Send to Claude", expr = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "NvimTree", "neo-tree", "oil" },
        callback = function(ev)
          vim.keymap.set("n", "<leader>as", claude_cmd("ClaudeCodeTreeAdd"), { buffer = ev.buf, desc = "Add file" })
        end,
      })
      vim.keymap.set("n", "<leader>aa", claude_cmd("ClaudeCodeDiffAccept"), { desc = "Accept diff" })
      vim.keymap.set("n", "<leader>ad", claude_cmd("ClaudeCodeDiffDeny"), { desc = "Deny diff" })

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
