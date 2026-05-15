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
          typescript = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          vue = [ "prettier" ];
          sh = [ "shfmt" ];
        };
        default_format_opts = {
          timeout_ms = 3000;
          lsp_format = "fallback";
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
