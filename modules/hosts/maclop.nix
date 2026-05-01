{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    openscreen
    cocoapods
    flutter
  ];

  catppuccin.obs = {
    enable = true;
    flavor = "macchiato";
  };

  programs.vscode = {
    enable = true;
  };
}
