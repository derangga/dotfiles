require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map(
  "n",
  "<leader>tt",
  ":lua require('base46').toggle_transparency()<CR>",
  { noremap = true, silent = true, desc = "Toggle Background Transparency" }
)

-- LSP mapping
map("n", "H", vim.lsp.buf.hover, { desc = "LSP Hover code" })
map("n", "<leader>gr", vim.lsp.buf.references, { desc = "LSP go to references" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })

-- LazyGit
map("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "Toggle open LazyGit" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- GitSign
local gitsigns = require "gitsigns"
map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle git line blame" })
