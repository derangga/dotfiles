{ ... }:

{
  programs.nixvim = {
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "macchiato";
        transparent_background = true;
        integrations = {
          blink_cmp = true;
          bufferline = true;
          dap = true;
          dap_ui = true;
          diffview = true;
          flash = true;
          gitsigns = true;
          headlines = true;
          lsp_trouble = true;
          markdown = true;
          mini = {
            enabled = true;
          };
          native_lsp = {
            enabled = true;
            inlay_hints = {
              background = true;
            };
            underlines = {
              errors = [ "underline" ];
              hints = [ "underline" ];
              information = [ "underline" ];
              warnings = [ "underline" ];
            };
          };
          noice = true;
          rainbow_delimiters = true;
          render_markdown = true;
          semantic_tokens = true;
          snacks = true;
          telescope.enabled = true;
          treesitter = true;
          treesitter_context = true;
          ts_rainbow = false;
          which_key = true;
        };
      };
    };
  };
}
