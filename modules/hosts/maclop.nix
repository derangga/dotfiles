{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    dbeaver-bin

    # flutter installation
    # cocoapods
    # flutter
  ];

  catppuccin.obs.enable = true;
}
