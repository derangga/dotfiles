return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      css = { "prettier" },
      go = { "goimports", "gofumpt" },
      html = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      json = { "prettier" },
      nix = { "nixfmt" },
      sh = { "shfmt" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      vue = { "prettier" },
    },
  },
}
