require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

-- Show smear cursor effect
-- autocmd("BufEnter", {
--   callback = function()
--     vim.fn.timer_start(70, function()
--       require("smear_cursor").enabled = true
--     end)
--   end,
-- })

-- Show diagnostics text on cursor hold
-- https://github.com/naborisk/dotfiles/blob/383041e06c070d78e4d990b662cfa13d35ce0a64/nvim/after/plugin/nvim-lspconfig.lua#L169-L172
local lspGroup = vim.api.nvim_create_augroup("Lsp", { clear = true })
autocmd("CursorHold", {
  command = "lua vim.diagnostic.open_float()",
  group = lspGroup,
})
