{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    cloudflared
  ];

  programs.vscode = {
    enable = true;
  };
}
