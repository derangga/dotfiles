{ ... }:

{
  programs.neovim = {
    enable = true;
  };

  xdg.configFile."nvim" = {
    source = ./plugins;
    recursive = true;
  };
}
