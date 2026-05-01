-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map("i", "jk", "<ESC>")

-- Comment
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- GitSign
local gitsigns = require("gitsigns")
map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle git line blame" })

-- FFF
map("n", "<leader>fz", function()
  require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
end, { desc = "Live fffuzy grep" })
map("n", "<leader>ff", function()
  require("fff").find_files()
end, { desc = "Find files (fff)" })
map("n", "<leader><space>", function()
  require("fff").find_files()
end, { desc = "Find files (fff)" })
map("n", "<leader>sg", function()
  require("fff").live_grep()
end, { desc = "Live grep (fff)" })

-- Diffview
map("n", "<leader>gd", function()
  if next(require("diffview.lib").views) ~= nil then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
  end
end, { desc = "Toggle Diff View" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History (current)" })

-- Window
map("n", "<Esc>b", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width (alt+arrow left)" })
map("n", "<Esc>f", "<cmd>vertical resize +2<CR>", { desc = "Increase window width (alt+arrow right)" })
map("n", "<M-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height (alt+arrow up)" })
map("n", "<M-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height (alt+arrow down)" })
