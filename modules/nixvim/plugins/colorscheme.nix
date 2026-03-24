{ ... }:

{
  programs.nixvim = {
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "macchiato";
        transparent_background = true;
        integrations = {
          flash = true;
          gitsigns = true;
          mini = { enabled = true; };
          noice = true;
          snacks = true;
          treesitter = true;
          treesitter_context = true;
          which_key = true;
        };
      };
    };
  };
}
