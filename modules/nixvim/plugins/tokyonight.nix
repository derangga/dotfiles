{ ... }:

{
  programs.nixvim = {
    colorschemes.tokyonight = {
      enable = true;
      settings = {
        style = "storm";
        transparent = true;
        terminal_colors = true;
        styles = {
          comments = {
            italic = true;
          };
          keywords = {
            italic = true;
          };
          sidebars = "transparent";
          floats = "transparent";
        };
      };
    };
  };
}
