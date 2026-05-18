{
  pkgs,
  catppuccin,
  nixvim,
  username,
  modulesDir,
  ...
}:

{
  imports = [
    catppuccin.homeModules.catppuccin
    nixvim.homeModules.nixvim
    modulesDir
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.11";
}
