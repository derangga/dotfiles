{
  pkgs,
  ...
}:

{
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    extraPackages = with pkgs; [
      fd
      gcc
      lua
      nil
      nixfmt
      ripgrep
    ];
    viAlias = true;
    vimAlias = true;
    withPython3 = false;
    withRuby = false;
  };

  xdg.configFile."nvim" = {
    source = ./lazyvim;
    recursive = true;
  };
}
