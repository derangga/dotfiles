return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      css = { "biome" },
      go = { "goimports", "gofumpt" },
      html = { "prettier" },
      javascript = { "biome" },
      javascriptreact = { "biome" },
      json = { "biome" },
      nix = { "nixfmt" },
      sh = { "shfmt" },
      typescript = { "biome" },
      typescriptreact = { "biome" },
      vue = { "prettier" },
    },
  },
}
