{ ... }:

{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          lua = [ "stylua" ];
          css = [ "prettier" ];
          go = [ "goimports" "gofumpt" ];
          html = [ "prettier" ];
          javascript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          json = [ "prettier" ];
          nix = [ "nixfmt" ];
          rust = [ "rustfmt" ];
          typescript = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          vue = [ "prettier" ];
          sh = [ "shfmt" ];
        };
        default_format_opts = {
          timeout_ms = 3000;
          lsp_format = "fallback";
        };
        # Format on save, respecting the <leader>uf / <leader>uF autoformat toggles.
        format_on_save = {
          __raw = ''
            function(bufnr)
              if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
                return
              end
              return { timeout_ms = 3000, lsp_format = "fallback" }
            end
          '';
        };
      };
    };

    keymaps = [
      {
        mode = [ "n" "x" ];
        key = "<leader>cF";
        action.__raw = ''
          function()
            require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
          end
        '';
        options.desc = "Format Injected Langs";
      }
    ];
  };
}
