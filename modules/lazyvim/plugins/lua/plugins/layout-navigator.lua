-- Layout navigator: handles navigation between terminal splits and neovim splits.
-- Currently using vim-kitty-navigator for kitty terminal.
-- If using ghostty + tmux, uncomment the tmux-navigator config below and comment out kitty-navigator.

-- kitty-navigator (active)
return {
  "knubie/vim-kitty-navigator",
  lazy = false,
  keys = {
    { "<c-h>", "<cmd>KittyNavigateLeft<cr>" },
    { "<c-j>", "<cmd>KittyNavigateDown<cr>" },
    { "<c-k>", "<cmd>KittyNavigateUp<cr>" },
    { "<c-l>", "<cmd>KittyNavigateRight<cr>" },
  },
}

-- tmux-navigator (use this with ghostty + tmux)
-- return {
--   "christoomey/vim-tmux-navigator",
--   lazy = false,
--   cmd = {
--     "TmuxNavigateLeft",
--     "TmuxNavigateDown",
--     "TmuxNavigateUp",
--     "TmuxNavigateRight",
--     "TmuxNavigatePrevious",
--   },
--   keys = {
--     { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
--     { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
--     { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
--     { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
--     { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
--   },
-- }
