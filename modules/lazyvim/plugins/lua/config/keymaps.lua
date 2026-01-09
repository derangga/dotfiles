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

-- Window
map("n", "<Esc>b", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width (alt+arrow left)" })
map("n", "<Esc>f", "<cmd>vertical resize +2<CR>", { desc = "Increase window width (alt+arrow right)" })
map("n", "<M-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height (alt+arrow up)" })
map("n", "<M-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height (alt+arrow down)" })
