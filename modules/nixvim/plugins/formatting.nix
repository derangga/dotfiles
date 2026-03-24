{ ... }:

{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          lua = [ "stylua" ];
          css = [ "prettier" ];
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

    plugins.lint = {
      enable = true;
      lintersByFt = {
        fish = [ "fish" ];
      };
      autoCmd = {
        event = [
          "BufWritePost"
          "BufReadPost"
          "InsertLeave"
        ];
        callback.__raw = ''
          function()
            require("lint").try_lint()
          end
        '';
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
