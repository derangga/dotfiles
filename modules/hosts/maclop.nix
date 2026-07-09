{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    openscreen
    dbeaver-bin

    # flutter installation
    # cocoapods
    # flutter
  ];

  catppuccin.obs.enable = true;

  programs.vscode = {
    enable = true;
  };
}
