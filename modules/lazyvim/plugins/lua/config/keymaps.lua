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
map("n", "<M-a>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<M-f>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })
map("n", "<M-s>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<M-d>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
