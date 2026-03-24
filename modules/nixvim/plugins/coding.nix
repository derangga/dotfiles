{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.mini = {
      enable = true;
      modules = {
        pairs = { };
        ai = { };
      };
    };

    extraPlugins = [ pkgs.vimPlugins.nvim-ts-context-commentstring ];

    extraConfigLua = ''
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    '';
  };
}
