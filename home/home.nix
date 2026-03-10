{
  pkgs,
  catppuccin,
  username,
  modulesDir,
  ...
}:

{
  imports = [
    catppuccin.homeModules.catppuccin
    modulesDir
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "25.11";
}
