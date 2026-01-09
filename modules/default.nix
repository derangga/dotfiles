{
  pkgs,
  hostname,
  username,
  ...
}:
{
  imports = [
    ./aerospace/config.nix
    ./catppuccin/config.nix
    ./lazyvim/config.nix
    ./starship/config.nix
    ./sketchybar/config.nix
    ./users/${username}.nix
  ];

  home.packages = with pkgs; [
    dbeaver-bin
  ];

  programs.bat = {
    enable = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
    };
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "always";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];
  };

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.vscode = {
    enable = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };
}
