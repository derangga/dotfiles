{ ... }:

{
  programs.nixvim = {
    plugins.lint = {
      enable = true;
      lintersByFt = {
        fish = [ "fish" ];
      };
    };

    extraConfigLua = ''
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          require("lint").try_lint()
        end,
      })
    '';
  };
}
