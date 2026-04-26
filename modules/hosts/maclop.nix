{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    cloudflared
    openscreen
  ];

  catppuccin.obs = {
    enable = true;
    flavor = "macchiato";
  };

  programs.vscode = {
    enable = true;
  };
}
