-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local autocmd = vim.api.nvim_create_autocmd

-- Show smear cursor effect
autocmd("BufEnter", {
  callback = function()
    vim.fn.timer_start(70, function()
      require("smear_cursor").enabled = true
    end)
  end,
})

-- Show diagnostics text on cursor hold
-- https://github.com/naborisk/dotfiles/blob/383041e06c070d78e4d990b662cfa13d35ce0a64/nvim/after/plugin/nvim-lspconfig.lua#L169-L172
local lspGroup = vim.api.nvim_create_augroup("Lsp", { clear = true })
autocmd("CursorHold", {
  command = "lua vim.diagnostic.open_float()",
  group = lspGroup,
})
