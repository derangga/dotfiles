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
  };

  xdg.configFile."nvim" = {
    source = ./plugins;
    recursive = true;
  };
}
