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
    ./hosts/${hostname}.nix
  ];

  home.packages = with pkgs; [ ];

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

  programs.tmux = {
    baseIndex = 1;
    clock24 = true;
    enable = true;
    customPaneNavigationAndResize = true;
    escapeTime = 10;
    focusEvents = true;
    keyMode = "vi";
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
  };

  programs.vscode = {
    enable = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  # llm tools
  programs.claude-code = {
    enable = true;
  };

  programs.opencode = {
    enable = true;
  };
}
