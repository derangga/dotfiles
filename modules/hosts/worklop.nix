{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    pm2
  ];
}
